exports.handler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "نطق مصطلح API فعال است!",
      status: "کار می‌کند",
      service: "Netlify Functions",
      timestamp: new Date().toISOString()
    })
  };
};
