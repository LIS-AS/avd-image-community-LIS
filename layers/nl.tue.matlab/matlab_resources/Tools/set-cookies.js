const { chromium } = require('./pw/node_modules/playwright');

(async () => {

    const userProfile = process.env.LOCALAPPDATA +
        '\\Microsoft\\Edge\\User Data';

    const context = await chromium.launchPersistentContext(userProfile, {
        channel: 'msedge',
        headless: false
    });

    await context.addCookies([
        {
            name: 'euconsent-v2',
            value: 'CQkdJAAQkdJAAAKA9AENCfFgAAAAAEPAACiQAAAY9ggAALACGAQgBeYDJAGfANFAjWBK0CpYFToKpAqmBVaCrgKugVgArIBWmCtgK2gVvAriBXMCvIFfILBAsKBYuCxwLHgWTAsqBZkCzwFoALTQWrBa0C2EFuAW5gt2C3gFwALhAXFguOC5EFywXMgusC7AF2oLugvABeQC9QF7IL7gvwBfuC_oL_wYBBgIDAkGBgYHAwUBg0DCUGFwYeAxABiIDFMGKwYsgxeDGEGMgY0Ax6AA.IMewJAAFgBDAC-AI0AhABJwEJAIcARqAl8BN4C8AF5gMkAZ8A0UB_gEZgI1gStAofBUcFSYKlgqxBVoFXoKwAraBW8CuIFcwK7QV4BXyCvwLDgWJgsWCx8FkQXagu4DEEGIgY9AA.YAAAAAAAAAAA',
            domain: '.mathworks.com',
            path: '/',
            expires: Math.floor(new Date('2027-06-13T15:08:55').getTime() / 1000),
            secure: true,
            sameSite: 'None'
        },
        {
            name: 'mwa_prefs',
            value: '%7B%22domain%22%3A%22us%22%2C%22lang%22%3A%22%22%2C%22v%22%3A2%7D',
            domain: '.mathworks.com',
            path: '/',
            expires: Math.floor(new Date('2027-06-23T15:08:55').getTime() / 1000),
            secure: true,
            sameSite: 'None'
        }
    ]);

    const page = await context.newPage();
    await page.goto('https://www.mathworks.com');

    await page.waitForTimeout(4000);

    await context.close();
})();