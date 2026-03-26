const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8080';

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'frontend' });
});

app.get('/', async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_URL}/api/accounts`);
    res.render('index', { accounts: response.data, error: null });
  } catch (err) {
    res.render('index', { accounts: [], error: 'Backend unavailable' });
  }
});
app.post('/accounts', async (req, res) => {
  try {
    await axios.post(`${BACKEND_URL}/api/accounts`, req.body);
    res.redirect('/');
  } catch (err) { res.redirect('/'); }
});

app.listen(PORT, () => console.log(`Frontend running on port ${PORT}`));