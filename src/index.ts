import { Hono } from "hono";
import { patternHandler } from "./handler/pattern_handler";
import { serveStatic } from "hono/bun";

const app = new Hono();

// Mount API routes first
app.route("/pattern", patternHandler);

// Serve pattern assets
app.use("/asset/*", serveStatic({ root: "./" }));

// Serve Svelte app static files (CSS, JS, etc)
app.use("/assets/*", serveStatic({ root: "./ui/dist" }));

// Serve other static files from public folder
app.use("/verdex.png", serveStatic({ root: "./ui/dist" }));
app.use("/vite.svg", serveStatic({ root: "./ui/dist" }));

// Serve index.html for all other routes (SPA fallback)
app.get("*", serveStatic({ path: "./ui/dist/index.html" }));

app.onError((err, c) => {
  console.error(err);
  return c.json({ success: false, message: err.message }, 500);
});

export default app;
