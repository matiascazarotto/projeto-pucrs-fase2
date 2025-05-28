const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Olá! Esta é uma aplicação de estudos da materia de DevOps.');
});

app.get('/status', (req, res) => {
  res.json({ status: 'UP', message: 'Serviço está operacional.' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
  });
}

module.exports = app;

