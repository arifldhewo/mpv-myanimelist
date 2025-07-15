# Problem Statement

I feel annoyed with manually update my anime progress from another third-party apps. So I build this plugin instead. This the first step as able to manually trigger by hotkeys. In the future I want to build it with automatically update at certain percentage of video duration.

# Pre-requisite

#### `Currently only support update if you're using my anime-scrape repo: [anime-scrape](https://github.com/arifldhewo/anime-scrape)`

# Step 0 | Clone this repository

1. git clone https://github.com/arifldhewo/mpv-myanimelist.git

# Step 1 | Create API license in order to get ClientID

1. Visit this link https://myanimelist.net/apiconfig
2. Click `Create ID` button.
3. Field `App Type` should choose `other`
4. Field `App Redirect URL` should type: `http://localhost:3000/redirect`
5. The rest is up to you.
6. Create and should redirect to main menu.
7. Click `Edit` button and copy the client_id value. and save it somewhere in your computer.

# Step 2 | Get JWT Credential from MAL OAuth2.0

1. Open folder `mal-oauth2`
2. type `npm install` in your terminal
3. Open file `config.js`
4. Put Your client ID on that config.CLIENT_ID
5. type `node server.js` in your terminal
6. open your browser and type `localhost:3000`
7. click Authorize and will return a data something like below

```json
{
	"token_type": "Bearer",
	"expires_in": 2678400,
	"access_token": "a1b2c3d4e5...",
	"refresh_token": "z9y8x7w6u5..."
}
```

8. Copy access_token **values** and save it somewhere in your computer

# Step 3

1. Open file `callmyanimelist.lua`
2. Put your access_token value into variable `malToken`
3. Copy file `callmyanimelist.lua`
4. Paste the file to this path `%appdata%\mpv.net\scripts\`
5. It's basically already done.

# Step 4

1. Open any video you like from my outputm3u folder.
2. Then when video is loaded
3. Hit `Ctrl+Shift+F`
4. Check Your myanimelist to validate
