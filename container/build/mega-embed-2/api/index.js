import express from 'express';
import { getSources } from './mega.js';

const app = express();
app.use(express.json());

app.get('/get', async (req, res) => {
  try {
    let embedUrl = req.query.url;
    if (!embedUrl || embedUrl === "") {
      res.status(404).json({ Error: 'No URL provided.' });
      return;
    } else {
      try {
        new URL(decodeURI(embedUrl));
      } catch (e) {
        res.status(404).json({ Error: 'Invalid URL provided.' });
        return;
      }
    }
    embedUrl = decodeURI(embedUrl);
    const result = await getSources(embedUrl, "https://hianime.to/");
    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ Error: 'Internal server error' });
  }
});

app.get('/:xrax', async (req, res) => {
  try {
    const { xrax } = req.params;
    if (!xrax || xrax === "") {
      res.status(404).json({ Error: 'Invalid API request' });
      return;
    }
    const result = await getSources(`https://megacloud.blog/embed-2/v3/e-1/${xrax}?k=1`, "https://hianime.to/");
    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ Error: 'Internal server error' });
  }
});

// 404 Middleware
app.use((req, res) => {
  res.status(404).json({ Error: 'Invalid API request' });
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
