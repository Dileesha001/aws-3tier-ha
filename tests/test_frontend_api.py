"""API integration contract tests; no real RDS connection or credentials needed."""
import importlib.util
from pathlib import Path
import unittest
import os
import json
import tempfile
from unittest.mock import MagicMock, patch

spec = importlib.util.spec_from_file_location("guestbook_app", Path(__file__).parents[1] / "app" / "app.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class FrontendContractTests(unittest.TestCase):
    def setUp(self):
        self.client = module.app.test_client()

    def test_health_and_built_frontend(self):
        self.assertEqual(self.client.get("/health").json, {"status": "ok"})
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        if (module.FRONTEND_DIST / "index.html").exists():
            self.assertIn(b"Cloudbook", response.data)
        response.close()

    def test_api_and_legacy_routes_share_database_results(self):
        connection = MagicMock()
        connection.__enter__.return_value = connection
        connection.execute.return_value.fetchall.return_value = [{"id": 1, "name": "Visitor", "message": "Hello", "created_at": "2026-10-08"}]
        with patch.object(module, "connect_db", return_value=connection):
            self.assertEqual(self.client.get("/api/messages").json, self.client.get("/messages").json)

    def test_parameterized_write_and_validation(self):
        self.assertEqual(self.client.post("/api/messages", json={"name": "", "message": "Hello"}).status_code, 400)
        connection = MagicMock()
        connection.__enter__.return_value = connection
        connection.execute.return_value.fetchone.return_value = {"id": 2, "name": "Visitor", "message": "Hello", "created_at": "2026-10-08"}
        with patch.object(module, "connect_db", return_value=connection):
            response = self.client.post("/api/messages", json={"name": " Visitor ", "message": " Hello "})
        self.assertEqual(response.status_code, 201)
        self.assertEqual(connection.execute.call_args.args[1], ("Visitor", "Hello"))

    def test_local_database_persists_validated_messages(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.dict(os.environ, {"LOCAL_DB_PATH": str(Path(directory) / "messages.sqlite3")}):
                self.assertEqual(self.client.get("/api/messages").json, [])
                response = self.client.post("/api/messages", json={"name": " Visitor ", "message": " Hello "})
                self.assertEqual(response.status_code, 201)
                record = response.json
                self.assertEqual(record["name"], "Visitor")
                self.assertEqual(record["message"], "Hello")
                self.assertTrue(record["created_at"].endswith("Z"))
                self.assertEqual(module.app.test_client().get("/api/messages").json, [record])
                self.assertEqual(self.client.get("/messages").json, [record])
                self.assertEqual(self.client.post("/api/messages", json={"name": " ", "message": "Hello"}).status_code, 400)

    def test_notification_payload_and_email_failure_preserve_saved_message(self):
        with tempfile.TemporaryDirectory() as directory:
            settings = {"LOCAL_DB_PATH": str(Path(directory) / "messages.sqlite3"),
                        "RESEND_API_KEY": "test-secret", "NOTIFICATION_EMAIL": "owner@example.com"}
            with patch.dict(os.environ, settings), patch.object(module.urllib.request, "urlopen") as send:
                send.return_value.__enter__.return_value.status = 200
                response = self.client.post("/api/messages", json={"name": "Visitor", "message": "Hello <world>"})
                self.assertEqual(response.status_code, 201)
                request = send.call_args.args[0]
                payload = json.loads(request.data)
                self.assertEqual(request.full_url, "https://api.resend.com/emails")
                self.assertEqual(payload["to"], ["owner@example.com"])
                self.assertIn("Hello <world>", payload["text"])
                self.assertIn("Visitor", payload["text"])
                self.assertNotIn(b"test-secret", response.data)
                send.reset_mock()
                self.client.get("/api/messages")
                self.client.post("/api/messages", json={"name": "", "message": "Hello"})
                send.assert_not_called()
                send.side_effect = TimeoutError("private diagnostic")
                response = self.client.post("/messages", json={"name": "Second", "message": "Saved despite mail failure"})
                self.assertEqual(response.status_code, 201)
                self.assertEqual(len(self.client.get("/api/messages").json), 2)

    def test_postgres_notification_runs_after_commit(self):
        connection = MagicMock()
        connection.__enter__.return_value = connection
        record = {"id": 4, "name": "Visitor", "message": "Hello", "created_at": "2026-10-13"}
        connection.execute.return_value.fetchone.return_value = record
        def check_commit(saved):
            connection.__exit__.assert_called_once_with(None, None, None)
            self.assertEqual(saved, record)
        with patch.object(module, "connect_db", return_value=connection), patch.object(module, "notify_owner", side_effect=check_commit) as notify:
            self.assertEqual(self.client.post("/api/messages", json={"name": "Visitor", "message": "Hello"}).status_code, 201)
            notify.assert_called_once_with(record)

    def test_unconfigured_notifications_do_not_send(self):
        with patch.dict(os.environ, {"RESEND_API_KEY": "", "NOTIFICATION_EMAIL": ""}), patch.object(module.urllib.request, "urlopen") as send:
            module.notify_owner({"id": 1})
            send.assert_not_called()

    def test_database_failure_is_generic(self):
        with patch.object(module, "connect_db", side_effect=module.psycopg.OperationalError("private diagnostic")):
            response = self.client.get("/api/messages")
        self.assertEqual(response.status_code, 503)
        self.assertNotIn(b"private diagnostic", response.data)


if __name__ == "__main__":
    unittest.main()
