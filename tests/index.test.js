const request = require("supertest");
const app = require("../src/index"); // Nosso arquivo principal da aplicação Express

describe("Testes das Rotas da Aplicação Express", () => {
  describe("GET /", () => {
    it("deve retornar status 200 e a mensagem de Olá", async () => {
      const res = await request(app).get("/");
      expect(res.statusCode).toEqual(200);
      expect(res.text).toBe("Olá! Esta é uma aplicação de estudos da materia de DevOps.");
    });
  });

  describe("GET /status", () => {
    it("deve retornar status 200 e um objeto JSON com status UP", async () => {
      const res = await request(app).get("/status");
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty("status", "UP");
      expect(res.body).toHaveProperty("message", "Serviço está operacional.");
    });
  });

  // Teste para uma rota inexistente
  describe("GET /rota-inexistente", () => {
    it("deve retornar status 404", async () => {
      const res = await request(app).get("/rota-inexistente");
      expect(res.statusCode).toEqual(404);
    });
  });
});

