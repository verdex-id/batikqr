import { Hono } from "hono";
import { patternHandler } from "./handler/pattern_handler";
import { serveStatic } from "hono/bun";

const app = new Hono();

// Mount static files
app.use("/asset/*", serveStatic({ root: "./" }));

app.onError((err, c) => {
    console.error(err);
    return c.json({ success: false, message: err.message }, 500);
});

app.route("/pattern", patternHandler);

export default app;
