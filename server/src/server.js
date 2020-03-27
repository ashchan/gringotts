import express from "express";
const app = express();
const port = 3000;

app.get("/", async (req, res) => {
  res.send("Hello World!");
});

app.listen(port, () => console.log(`Server started on port ${port}!`));
