
EduVerifica
Aplicación Móvil Educativa contra la Desinformación

1. Descripción del Proyecto
EduVerifica es una aplicación móvil educativa desarrollada como proyecto final del Diplomado en Desarrollo Web y Móvil Full Stack. Su objetivo principal es combatir la desinformación digital mediante la alfabetización mediática y el fortalecimiento del pensamiento crítico, proporcionando herramientas interactivas para verificar información y detectar noticias falsas.
La aplicación integra verificaciones realizadas por organizaciones humanas a través de Google Fact Check API con análisis generativo de inteligencia artificial mediante Gemini 2.5 Flash, ofreciendo una experiencia integral de validación informativa.
2. Arquitectura del Sistema
El sistema implementa una arquitectura Cliente–Servidor basada en Backend-as-a-Service (BaaS). El frontend está desarrollado en Flutter, mientras que el backend utiliza Supabase (PostgreSQL + Auth + Row Level Security). La aplicación se integra además con APIs externas como Google Fact Check API y Gemini 2.5 Flash.
3. Stack Tecnológico
<img width="737" height="393" alt="image" src="https://github.com/user-attachments/assets/92a50325-ca2b-4e51-aa75-bc016c9d43cc" />

4. Seguridad
El sistema implementa autenticación basada en JSON Web Tokens (JWT), políticas Row Level Security (RLS) en todas las tablas de la base de datos y comunicación cifrada mediante HTTPS. El acceso a la información se encuentra restringido según el usuario autenticado.
5. Estado del Proyecto
El prototipo se encuentra funcional con un nivel de implementación promedio del 92.8%. Incluye autenticación completa, módulos educativos, glosario interactivo, simulador de detección de desinformación, verificador mediante inteligencia artificial y consulta de verificaciones humanas.
6. Autor
Moisés Navajas Bernal
Diplomado en Desarrollo Web y Móvil Full Stack
La Paz - Bolivia, 2026
Correo electrónico: moinavajas97@gmail.com
GitHub: @GatoSoberano
