"""API integration contract tests; no real RDS connection or credentials needed."""
import importlib.util
from pathlib import Path
import unittest
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

    def test_database_failure_is_generic(self):
        with patch.object(module, "connect_db", side_effect=module.psycopg.OperationalError("private diagnostic")):
            response = self.client.get("/api/messages")
        self.assertEqual(response.status_code, 503)
        self.assertNotIn(b"private diagnostic", response.data)


if __name__ == "__main__":
    unittest.main()
