📱 Notícias Mundiais
Aplicativo Flutter que exibe notícias sobre conflitos globais usando dados da API da ACLED. Conta com autenticação via Firebase, opção de seguir notícias e adicionar anotações pessoais.

🚀 Funcionalidades
Busca de Notícias: Integração com a API da ACLED.

Login e Registro: Autenticação de usuários via Firebase.

Seguir Notícias: Salva artigos favoritos no Firestore.

Notas Pessoais: Permite adicionar e editar anotações nos artigos seguidos.

Pesquisa: Filtra notícias por palavra-chave, país ou tipo de evento.

Visualização Detalhada: Exibe detalhes do artigo e opções para seguir ou adicionar notas.

Tela de Favoritos: Lista todas as notícias seguidas pelo usuário.

🛠️ Tecnologias Usadas
Flutter

Firebase Authentication & Firestore

Provider (gerenciamento de estado)

HTTP (requisições à API ACLED)

CORS Proxy (contornar bloqueios da API)

⚙️ Como Configurar
Instale o Flutter.

Configure um projeto no Firebase.

Ative Authentication e Firestore.

Adicione o arquivo firebase_options.dart ao projeto.

Insira sua chave da API ACLED em utils/config.dart.

Rode flutter pub get para instalar as dependências.

Execute com flutter run.
