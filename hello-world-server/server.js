const express = require('express');
const app = express();

app.use(express.json());
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  next();
});

app.options('*', (req, res) => res.sendStatus(204));

app.get('/', (req, res) => {
   res.send('Hello World');
});

app.post('/greet', (req, res) => {
  const { name } = req.body;
  res.send(`hello ${name}`);
});

app.listen(3000, () => {
   console.log('Server running on port 3000');
});