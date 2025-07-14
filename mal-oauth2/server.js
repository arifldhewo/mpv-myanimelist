const express = require("express");
const qs = require("qs");
const axios = require("axios").default;
const { config } = require("./config");
const helper = require("./helper");
const app = express();
const port = 3000;
const malBaseURL = "https://myanimelist.net";

app.get("/", (_, res) => {
	const authUrl =
		`${malBaseURL}/v1/oauth2/authorize?` +
		new URLSearchParams({
			response_type: "code",
			client_id: config.CLIENT_ID,
			code_challenge: helper.codeChallenge,
		}).toString();

	res.redirect(authUrl);
});

app.get("/redirect", async (req, res) => {
	const { code } = req.query;

	if (!code) {
		res.status(500).send("Missing Authorization Code In Query Params");
	}

	const data = qs.stringify({
		client_id: config.CLIENT_ID,
		code: code,
		code_verifier: helper.codeChallenge,
		grant_type: "authorization_code",
	});

	await axios
		.post("/v1/oauth2/token", data, {
			baseURL: malBaseURL,
			headers: {
				"Content-Type": "application/x-www-form-urlencoded",
			},
		})
		.then((response) => {
			res.status(200).json({ data: response.data });
		})
		.catch((err) => {
			res.status(500).json({ error: err, message: "Contect me" });
		});
});

app.listen(port, () => {
	console.log(`Example app listening on port ${port}`);
});
