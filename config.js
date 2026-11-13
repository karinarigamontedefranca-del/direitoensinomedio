// Configuração da pesquisa. Edite apenas este arquivo.
// A chave "anon" do Supabase é pública por design: quem protege os dados é a RLS (veja supabase.sql).
// NUNCA coloque aqui a chave "service_role".
window.PESQUISA_CONFIG = {
  SUPABASE_URL: "https://ngkmsropdqhqogcrjylb.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5na21zcm9wZHFocW9nY3JqeWxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ0MDY4MzYsImV4cCI6MjEwOTk4MjgzNn0.3ZzEIvHyaDgFOBveuoEbIpW1OhSV8k60TcsStguR3yc",
  TABELA: "respostas_ensino_medio",
  VERSAO: "1.0",

  // Faculdades usadas na pergunta de lembrança de marca (a SKEMA aparece misturada, sem destaque).
  // Lista a validar com a SKEMA. A ordem é embaralhada para cada respondente.
  FACULDADES: ["PUC Minas", "Dom Helder", "Milton Campos", "Ibmec", "UFMG", "Newton Paiva", "UniBH", "FUMEC", "SKEMA"],

  // Cartão da proposta (mesmo texto dos demais públicos externos). Usa só os diferenciais descritos no contrato.
  CARTAO_TEXTO: "Formação jurídica integrada a negócios e tecnologia, com vivência internacional e possibilidade de mobilidade entre países, em uma escola de posicionamento global.",

  AVISO_URL: "#",                                   // link do aviso de privacidade completo
  CONTATO: "[e-mail de contato da SKEMA Consultoria Jr.]"
};
