import { expect, test } from '@playwright/test';

test('saves a real API response, refreshes the list, and renders content as text', async ({ page }) => {
  const records = [{ id: 1, name: 'First visitor', message: 'Hello from the cloud.', created_at: '2026-10-08T12:00:00Z' }];
  await page.route('**/health', route => route.fulfill({ json: { status: 'ok' } }));
  await page.route('**/api/messages', async route => {
    if (route.request().method() === 'POST') {
      const body = route.request().postDataJSON();
      expect(body).toEqual({ name: 'Dileesha', message: '<script>alert(1)</script>' });
      const record = { id: 2, ...body, created_at: '2026-10-08T12:05:00Z' };
      records.unshift(record);
      await route.fulfill({ status: 201, json: record });
    } else await route.fulfill({ json: records });
  });
  await page.goto('/');
  await expect(page.getByText('API available', { exact: true })).toBeVisible();
  await expect(page.getByText('Hello from the cloud.')).toBeVisible();
  await page.getByLabel('Your name', { exact: true }).fill('  Dileesha  ');
  await page.getByLabel('Your message', { exact: true }).fill('<script>alert(1)</script>');
  await page.getByRole('button', { name: 'Send a little hello' }).click();
  await expect(page.getByText('Your message is saved.', { exact: false })).toBeVisible();
  await expect(page.locator('article').first()).toContainText('<script>alert(1)</script>');
  await expect(page.getByLabel('Your message', { exact: true })).toHaveValue('');
  await page.getByRole('button', { name: 'Refresh messages' }).click();
  await expect(page.locator('article')).toHaveCount(2);
});

test('shows database failure independently from API health and can retry', async ({ page }) => {
  let unavailable = true;
  await page.route('**/health', route => route.fulfill({ json: { status: 'ok' } }));
  await page.route('**/api/messages', route => route.fulfill(unavailable ? { status: 503, json: { error: 'Database temporarily unavailable' } } : { json: [] }));
  await page.goto('/');
  await expect(page.getByText('API available', { exact: true })).toBeVisible();
  await expect(page.getByText('Database temporarily unavailable')).toBeVisible();
  unavailable = false;
  await page.getByRole('button', { name: 'Try again' }).click();
  await expect(page.getByText('A fresh page, waiting for you.')).toBeVisible();
});

test('retains a failed submission and fits a mobile screen', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.route('**/health', route => route.fulfill({ json: { status: 'ok' } }));
  await page.route('**/api/messages', route => route.fulfill(route.request().method() === 'POST' ? { status: 503, json: { error: 'Database temporarily unavailable' } } : { json: [] }));
  await page.goto('/');
  await page.getByLabel('Your name', { exact: true }).fill('Visitor');
  await page.getByLabel('Your message', { exact: true }).fill('Keep this draft');
  await page.getByRole('button', { name: 'Send a little hello' }).click();
  await expect(page.getByRole('alert')).toContainText('Database temporarily unavailable');
  await expect(page.getByLabel('Your message', { exact: true })).toHaveValue('Keep this draft');
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
});
