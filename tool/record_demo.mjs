import fs from 'node:fs/promises';
import { chromium } from 'playwright';

const project = process.env.DEMO_PROJECT;
if (!project) throw new Error('DEMO_PROJECT is required');

await fs.mkdir('demo', { recursive: true });
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: project === 'profile-card-app'
    ? { width: 390, height: 844 }
    : { width: 1000, height: 800 },
  deviceScaleFactor: 1,
  recordVideo: { dir: 'demo-recording', size: { width: 1000, height: 800 } },
});
const page = await context.newPage();

try {
  await page.goto('http://127.0.0.1:4173/', { waitUntil: 'networkidle' });
  await page.waitForSelector('flt-glass-pane', { timeout: 30000 });
  await page.waitForTimeout(1600);

  const enableAccessibility = page.getByText('Enable accessibility', { exact: true });
  if (await enableAccessibility.count()) {
    await enableAccessibility.click();
    await page.waitForTimeout(900);
  }

  if (project === 'profile-card-app') {
    await page.getByText('Asha Verma', { exact: true }).waitFor({ state: 'visible' });
    await page.screenshot({ path: 'demo/profile-card-mobile.png', fullPage: true });
    await page.waitForTimeout(2600);
  } else if (project === 'tip-calculator-app') {
    const bill = page.getByRole('textbox', { name: 'Bill amount' });
    await bill.fill('1000');
    await page.waitForTimeout(900);
    const slider = page.getByRole('slider');
    if (await slider.count()) {
      await slider.focus();
      await slider.press('ArrowRight');
    }
    await page.getByRole('button', { name: 'Add one person' }).click();
    await page.waitForTimeout(1800);
  } else if (project === 'todo-list-app') {
    const input = page.getByRole('textbox', { name: 'What needs doing?' });
    for (const task of ['Plan the day', 'Read a chapter', 'Review the checklist']) {
      await input.fill(task);
      await page.getByRole('button', { name: 'Add' }).click();
    }
    await page.waitForTimeout(800);
    await page.getByRole('checkbox').first().click();
    await page.waitForTimeout(900);
    const taskRow = page.getByText('Read a chapter', { exact: true });
    const box = await taskRow.boundingBox();
    if (box) {
      const y = box.y + box.height / 2;
      await page.mouse.move(box.x + box.width - 8, y);
      await page.mouse.down();
      await page.mouse.move(box.x - 220, y, { steps: 14 });
      await page.mouse.up();
    }
    await page.waitForTimeout(1800);
  } else if (project === 'unit-converter-app') {
    await page.getByText('Length', { exact: true }).first().click();
    await page.getByRole('textbox', { name: 'Value' }).fill('1000');
    await page.waitForTimeout(1400);
    await page.getByRole('button', { name: 'Back' }).click().catch(() => page.keyboard.press('Alt+ArrowLeft'));
    await page.getByText('Temperature', { exact: true }).first().click();
    await page.getByRole('textbox', { name: 'Value' }).fill('0');
    await page.waitForTimeout(1800);
  } else if (project === 'quiz-app') {
    const answers = [
      'main()', 'Column', 'Row', 'Rebuild after state changes', 'ListView',
      'TextField', 'MaterialApp', 'FilledButton', 'bool', 'LinearProgressIndicator',
    ];
    for (let index = 0; index < answers.length; index++) {
      await page.getByRole('button', { name: answers[index], exact: true }).click();
      await page.waitForTimeout(230);
      const nextLabel = index === answers.length - 1 ? 'See results' : 'Next question';
      await page.getByRole('button', { name: nextLabel, exact: true }).click();
      await page.waitForTimeout(260);
    }
    await page.getByText('10 / 10', { exact: true }).waitFor({ state: 'visible' });
    await page.waitForTimeout(2200);
  } else {
    throw new Error(\`Unsupported project: \${project}\`);
  }
} finally {
  const video = page.video();
  await context.close();
  await browser.close();
  const recordedPath = await video.path();
  await fs.mkdir('demo-recording', { recursive: true });
  await fs.copyFile(recordedPath, \`demo-recording/\${project}.webm\`);
}
