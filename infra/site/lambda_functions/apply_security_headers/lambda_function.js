'use strict';
exports.handler = (event, context, callback) => {
	const response = event.Records[0].cf.response;
	const headers = response.headers;

	headers["strict-transport-security"] = [{key: "Strict-Transport-Security", value: "max-age=31536000; includeSubdomains; preload"}]; 
	headers["content-security-policy"] = [{key: "Content-Security-Policy", value: "default-src 'none'; connect-src *.fontawesome.com; img-src 'self'; script-src 'self' 'unsafe-inline' *.fontawesome.com; style-src 'self' 'unsafe-inline' fonts.googleapis.com *.fontawesome.com; font-src 'self' fonts.googleapis.com fonts.gstatic.com *.fontawesome.com; object-src 'none'"}]; 
	headers["x-content-type-options"] = [{key: "X-Content-Type-Options", value: "nosniff"}]; 
	headers["x-frame-options"] = [{key: "X-Frame-Options", value: "DENY"}]; 
	headers["x-xss-protection"] = [{key: "X-XSS-Protection", value: "1; mode=block"}]; 
	headers["referrer-policy"] = [{key: "Referrer-Policy", value: "same-origin"}]; 
	headers["feature-policy"] = [{key: "feature-policy", value: "accelerometer 'none'; camera 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none'"}];
    
	callback(null, response);
};