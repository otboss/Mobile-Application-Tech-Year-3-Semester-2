const assert = require('assert');

describe('webdriver.io page', () => {
    it('should have the right title', async () => {
        await browser.url('https://webdriver.io');
        const title = await browser.getTitle();
	console.log("THE TITLE IS EQUAL TO: "+title);
        assert.equal(title, 'WebdriverIO · Next-gen WebDriver test framework for Node.js');
        await browser.url('http://example.com');
    });
});
