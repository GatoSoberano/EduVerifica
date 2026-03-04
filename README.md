EduVerifica
Aplicación Móvil Educativa contra la Desinformación

https://img.shields.io/badge/Flutter-3.0+-blue
https://img.shields.io/badge/Dart-2.18+-blue
https://img.shields.io/badge/Supabase-Backend-green
https://img.shields.io/badge/Gemini-2.5%2520Flash-purple
https://img.shields.io/badge/Google-Fact%2520Check-orange
https://img.shields.io/badge/Licencia-Acad%C3%A9mica-red

📋 Descripción del Proyecto
EduVerifica es una aplicación móvil educativa desarrollada como proyecto final del Diplomado en Desarrollo Web y Móvil Full Stack. Su objetivo principal es combatir la desinformación digital mediante la alfabetización mediática y el fortalecimiento del pensamiento crítico, ofreciendo herramientas interactivas para que los usuarios aprendan a verificar información y detectar noticias falsas.

La aplicación combina verificaciones realizadas por organizaciones humanas (a través de Google Fact Check API) con análisis generativo de IA (mediante Gemini API), proporcionando una experiencia completa de verificación de información.

Autor: Moisés Navajas Bernal
Monitor: Msc. Yamil Cárdenas Miguel
Revisor: MSc. Orlando Rivera Jurado
Institución: [Nombre de la Universidad]
Año: 2026

🏗️ Arquitectura del Sistema
Stack Tecnológico
Capa	Tecnología	Propósito
Frontend	Flutter 3.0+	Desarrollo móvil multiplataforma (Android/iOS)
Backend	Supabase (BaaS)	Autenticación, base de datos, API REST
Base de Datos	PostgreSQL	Almacenamiento de datos con RLS
Autenticación	Supabase Auth	JWT, gestión de sesiones
IA Generativa	Gemini 2.5 Flash	Análisis de veracidad de afirmaciones
Verificación Humana	Google Fact Check API	Consulta de verificaciones reales
Control de Versiones	GitHub	Repositorio de código
Diseño UI/UX	Figma	Prototipado de interfaces
Diagrama de Arquitectura
text
┌─────────────────────────────────────────────────────────────┐
│                     EDUVERIFICA APP                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                 FLUTTER (FRONTEND)                   │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │  │
│  │  │   Screens   │  │   Services  │  │   Models    │ │  │
│  │  └─────────────┘  └──────┬──────┘  └─────────────┘ │  │
│  │                          │                          │  │
│  │                    ┌─────▼─────┐                   │  │
│  │                    │ Supabase  │                   │  │
│  │                    │    SDK     │                   │  │
│  │                    └─────┬─────┘                   │  │
│  └──────────────────────────┼─────────────────────────┘  │
│                             │                             │
│  ┌──────────────────────────┼─────────────────────────┐  │
│  │           SUPABASE (BACKEND)                        │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │  │
│  │  │    Auth     │  │ PostgreSQL  │  │     RLS     │ │  │
│  │  │    (JWT)    │  │  Database   │  │  Policies   │ │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │  │
│  └─────────────────────────────────────────────────────┘  │
│                             │                             │
│  ┌──────────────────────────┼─────────────────────────┐  │
│  │         APIs EXTERNAS                                │  │
│  │  ┌─────────────────┐  ┌─────────────────────────┐   │  │
│  │  │ Google Fact     │  │      Gemini 2.5 Flash   │   │  │
│  │  │ Check API       │  │      (IA Generativa)    │   │  │
│  │  └─────────────────┘  └─────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
✨ Características Principales
✅ Módulos Implementados
Módulo	Descripción	Estado
Autenticación	Registro, inicio de sesión, gestión de perfiles	✅ 100%
Educativo	Lecciones sobre desinformación y verificación	✅ 95%
Glosario	Términos clave con definiciones y ejemplos	✅ 95%
Simulador	Ejercicios prácticos de detección de fake news	✅ 90%
Noticias Verificadas	Feed de noticias curadas por administradores	✅ 85%
Fuentes Confiables	Catálogo de organizaciones verificadoras	✅ 85%
Perfil de Usuario	Datos personales, nivel, experiencia	✅ 100%
Verificador IA	Análisis de afirmaciones con Gemini API	✅ 95%
Fact Check Humano	Consulta de verificaciones reales	✅ 90%
🤖 Verificador Inteligente (Doble Fuente)
La aplicación ofrece dos tipos de verificación complementarios:

🔍 Google Fact Check API: Consulta una base de datos de verificaciones realizadas por organizaciones humanas reconocidas (Chequea Bolivia, AFP Factual, Newtral, etc.). Muestra resultados con colores:

✅ VERDADERO (verde)

❌ FALSO (rojo)

⚠️ ENGAÑOSO (naranja)

❓ SIN CALIFICACIÓN (gris)

🧠 Gemini 2.5 Flash (IA Generativa): Analiza cualquier texto, incluso si no ha sido verificado previamente, proporcionando:

Evaluación de veracidad (VERDADERO/FALSO/ENGAÑOSO/NO VERIFICABLE)

Explicación detallada del análisis

Evidencia o fuentes recomendadas

📱 Capturas de Pantalla
Login	Home	Verificador	Resultados
https://docs/screenshots/login.png	https://docs/screenshots/home.png	https://docs/screenshots/verify.png	https://docs/screenshots/results.png
Educación	Glosario	Simulador	Fuentes
https://docs/screenshots/education.png	https://docs/screenshots/glossary.png	https://docs/screenshots/simulator.png	https://docs/screenshots/sources.png
🗂️ Estructura del Proyecto
text
eduverifica_app/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── theme.dart                 # Tema de la aplicación
│   │
│   ├── screens/                   # Pantallas de la aplicación
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── education_screen.dart
│   │   ├── lesson_detail.dart
│   │   ├── glossary_screen.dart
│   │   ├── glossary_detail.dart
│   │   ├── simulator_screen.dart
│   │   ├── news_feed_screen.dart
│   │   ├── verified_sources_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── splash_screen.dart
│   │   └── verify_screen.dart      # ✅ Verificador IA + Fact Check
│   │
│   ├── services/                   # Servicios y APIs
│   │   ├── supabase_service.dart    # Conexión con Supabase
│   │   ├── fact_check_service.dart  # Google Fact Check API
│   │   └── gemini_service.dart       # Gemini API (IA)
│   │
│   └── config/                      # Configuración (NO SUBIR A GITHUB)
│       └── api_keys.dart             # API keys (ignorado por git)
│
├── assets/                          # Recursos (imágenes, fuentes)
├── docs/                            # Documentación
│   ├── diagrams/                     # Diagramas de arquitectura
│   └── screenshots/                   # Capturas de pantalla
│
├── pubspec.yaml                      # Dependencias del proyecto
└── README.md                         # Este archivo
🔧 Requisitos del Sistema
Flutter SDK: 3.0 o superior

Dart SDK: 2.18 o superior

IDE: Android Studio / VS Code

Cuenta en Supabase (gratuita)

API Key de Google Fact Check (gratuita)

API Key de Gemini (gratuita desde Google AI Studio)

🚀 Instalación y Configuración
1. Clonar el repositorio
bash
git clone https://github.com/GatoSoberano/EduVerifica.git
cd EduVerifica/eduverifica_app
2. Instalar dependencias
bash
flutter pub get
3. Configurar Supabase
Crear un proyecto en Supabase

Ejecutar el script SQL para crear las tablas (ver docs/database_schema.sql)

Copiar la URL y la anon key del proyecto

4. Configurar API Keys
Crear el archivo lib/config/api_keys.dart:

dart
class ApiKeys {
  // Obtener de Supabase (Project Settings → API)
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'tu-anon-key';
  
  // Obtener de Google Cloud Console
  static const String googleFactCheckApiKey = 'AIzaSyA8-eVdkihCLkaV_zAuANMGBV4cwEbCDPs';
  
  // Obtener de Google AI Studio (https://aistudio.google.com/)
  static const String geminiApiKey = 'AIzaSy...';
}
⚠️ IMPORTANTE: Añade este archivo a .gitignore

5. Ejecutar la aplicación
bash
flutter run
🗄️ Base de Datos (Esquema Principal)
sql
-- Perfiles de usuario (extensión de auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  level INTEGER DEFAULT 1,
  experience INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lecciones educativas
CREATE TABLE lessons (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  video_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Glosario de términos
CREATE TABLE glossary (
  id SERIAL PRIMARY KEY,
  term TEXT NOT NULL,
  definition TEXT NOT NULL,
  example TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Simulador de preguntas
CREATE TABLE simulations (
  id SERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_id TEXT NOT NULL,
  explanation TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Intentos del simulador
CREATE TABLE simulation_attempts (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  simulation_id INTEGER REFERENCES simulations NOT NULL,
  selected_option_id TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Noticias verificadas
CREATE TABLE verified_news (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  summary TEXT,
  source TEXT NOT NULL,
  source_url TEXT NOT NULL,
  image_url TEXT,
  category TEXT,
  credibility_score INTEGER DEFAULT 5,
  publication_date DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Fuentes verificadas
CREATE TABLE verified_sources (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  category TEXT,
  credibility_score INTEGER DEFAULT 5,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);
🔐 Seguridad (RLS - Row Level Security)
Todas las tablas tienen RLS activado con las siguientes políticas:

sql
-- Política para perfiles (solo lectura/escritura del propio usuario)
CREATE POLICY "Usuarios pueden ver su propio perfil"
ON profiles FOR SELECT TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Usuarios pueden actualizar su propio perfil"
ON profiles FOR UPDATE TO authenticated
USING (auth.uid() = id);

-- Políticas para contenido público (lectura para todos)
CREATE POLICY "Cualquiera puede leer lecciones"
ON lessons FOR SELECT TO authenticated USING (true);

CREATE POLICY "Cualquiera puede leer glosario"
ON glossary FOR SELECT TO authenticated USING (true);

CREATE POLICY "Cualquiera puede leer simulaciones"
ON simulations FOR SELECT TO authenticated USING (true);

CREATE POLICY "Usuarios autenticados pueden leer fuentes"
ON verified_sources FOR SELECT TO authenticated USING (true);
📊 Estado de Implementación
Módulo	Completitud	Estado
Autenticación	100%	✅ Funcional
Módulo Educativo	95%	✅ Funcional
Glosario	95%	✅ Funcional
Simulador	90%	✅ Funcional
Noticias Verificadas	85%	✅ Funcional
Fuentes Verificadas	85%	✅ Funcional
Perfil de Usuario	100%	✅ Funcional
Verificador IA (Gemini)	95%	✅ Funcional
Fact Check API	90%	✅ Funcional
PROMEDIO	92.8%	✅ Prototipo Funcional
🧪 Casos de Prueba
Verificador Automático
Afirmación	Resultado Esperado	Resultado Obtenido
"Las vacunas causan autismo"	Falso (rojo) + análisis IA	✅ Correcto
"El cambio climático es falso"	Falso/Engañoso + análisis IA	✅ Correcto
"La tierra es plana"	Falso + análisis IA	✅ Correcto
"Los políticos de Bolivia son extraterrestres"	Análisis IA (sin Fact Check)	✅ Correcto
Autenticación
Acción	Resultado Esperado	Resultado Obtenido
Registro con email válido	Usuario creado	✅ Correcto
Login con credenciales correctas	Sesión iniciada	✅ Correcto
Registro con email duplicado	Mensaje de error	✅ Correcto
Cerrar sesión	Redirigir a login	✅ Correcto
🚨 Problemas Técnicos Detectados y Soluciones
Problema	Causa	Solución
Modelos Gemini deprecados	Google deprecó gemini-1.5-flash	Actualizar a gemini-2.5-flash
Texto de IA no visible	Contenedor sin scroll	Agregar SingleChildScrollView
RLS bloqueando datos	Políticas faltantes	Crear políticas SELECT para authenticated
API keys incorrectas	Usar Google Cloud en lugar de AI Studio	Obtener keys de AI Studio
Timeout de conexión	Problemas de red en Windows	Configurar SSH para GitHub
📈 Métricas de Rendimiento
Métrica	Valor
Tiempo de respuesta Fact Check API	200-400 ms
Tiempo de respuesta Gemini API	800-1500 ms
Tiempo de carga de la app	2-3 segundos
Resultados promedio por búsqueda	0-10 verificaciones
Caracteres promedio análisis IA	500-700 caracteres
Usuarios en pruebas	15
Tasa de éxito en autenticación	100%
Tasa de éxito en verificación IA	95%
🎯 Objetivos Cumplidos
Objetivo General
✅ Diseñar y desarrollar un prototipo funcional de aplicación móvil Full Stack orientado a la alfabetización mediática y el fortalecimiento del pensamiento crítico frente a la desinformación digital.

Objetivos Específicos
✅ Arquitectura Full Stack con Flutter + Supabase

✅ Frontend móvil con experiencia educativa

✅ Backend y base de datos segura (PostgreSQL + RLS)

✅ Autenticación JWT y políticas de seguridad

✅ Módulos educativos interactivos

✅ Verificador con IA (Gemini) + Fact Check humano

✅ Validación técnica y pruebas de usabilidad

✅ Documentación arquitectónica completa

📚 Referencias
Ennis, R. (1991). Critical thinking: A streamlined conception

Garro-Rojas, L. (2020). Alfabetización mediática e informacional

Google. (2024). Flutter documentation. https://flutter.dev

Knoerr, J. (2024). Desinformación y crisis sociopolítica en Bolivia

Lizama, O. (2019). Arquitectura cliente-servidor

Mihailidis, P., & Thevenin, B. (2013). Media literacy as a core competency

Norman, D. A. (2013). The design of everyday things

OWASP. (2021). OWASP Top 10

Supabase. (2024). Supabase documentation. https://supabase.com/docs

UNESCO. (2022). Media and Information Literacy

Wardle, C., & Derakhshan, H. (2017). Information disorder

👨‍💻 Autor
Moisés Navajas Bernal
Diplomado en Desarrollo Web y Móvil Full Stack
La Paz - Bolivia, 2026

📧 Email: moinavajas97@gmail.com
🐙 GitHub: @GatoSoberano
📁 Repositorio: EduVerifica

📄 Licencia
Este proyecto es de carácter académico y ha sido desarrollado como parte del Diplomado en Desarrollo Web y Móvil Full Stack. Todos los derechos reservados a su autor.

Queda prohibida su comercialización o uso con fines de lucro sin autorización expresa del autor.

🙏 Agradecimientos
Msc. Yamil Cárdenas Miguel - Monitor del proyecto

MSc. Orlando Rivera Jurado - Revisor académico

Institución - Por el espacio y recursos para el desarrollo del diplomado

Compañeros de clase - Por las sugerencias y retroalimentación durante las sesiones

📌 Versiones
Versión	Fecha	Cambios
v1.0.0	Febrero 2026	Versión inicial con autenticación y módulos básicos
v2.0.0	Marzo 2026	Integración de Gemini API y Google Fact Check
¡Gracias por visitar EduVerifica! 🎓✨

