const crypto = require("crypto");

function generateCodeVerifier() {
	return crypto.randomBytes(32).toString("base64url");
}

function generateCodeChallenge(verifier) {
	return crypto.createHash("SHA256").update(verifier).digest("base64url");
}

const codeVerifier = generateCodeVerifier();
const codeChallenge = generateCodeChallenge(codeVerifier);

module.exports = {
	codeVerifier,
	codeChallenge,
};
