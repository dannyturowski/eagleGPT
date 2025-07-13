# GEMINI Local Development Guide

This document provides a guide for developers working on the Open WebUI project.

## Project Overview

Open WebUI is a self-hosted, extensible, and user-friendly AI platform designed to operate entirely offline. It supports various LLM runners like Ollama and OpenAI-compatible APIs, and includes features like local RAG, a model builder, and plugin support.

The project consists of a SvelteKit frontend and a Python FastAPI backend.

## Tech Stack

**Frontend:**

*   **Framework:** SvelteKit
*   **Language:** TypeScript
*   **Styling:** Tailwind CSS
*   **Testing:** Vitest, Playwright

**Backend:**

*   **Framework:** FastAPI
*   **Language:** Python
*   **Database:** SQLite (default), PostgreSQL, MySQL
*   **ORM:** SQLAlchemy
*   **Linting/Formatting:** pylint, black, ruff

## Getting Started

The recommended way to run the project is with Docker.

1.  **Prerequisites:**
    *   Docker installed and running.
    *   An environment file `.env` created from `.env.example`.

2.  **Run with Docker Compose:**
    ```bash
    docker-compose up -d
    ```
    This will start the application, and it will be accessible at `http://localhost:3000`.

## Development

### Frontend

*   **Run in development mode:**
    ```bash
    npm run dev
    ```
*   **Lint:**
    ```bash
    npm run lint:frontend
    ```
*   **Format:**
    ```bash
    npm run format
    ```
*   **Test:**
    ```bash
    npm run test:frontend
    ```

### Backend

*   **Lint:**
    ```bash
    npm run lint:backend
    ```
*   **Format:**
    ```bash
    npm run format:backend
    ```

## Key Files

*   `package.json`: Defines frontend dependencies and scripts.
*   `pyproject.toml`: Defines backend dependencies and project metadata.
*   `docker-compose.yml`: Defines the services for running the application with Docker.
*   `src/`: Contains the SvelteKit frontend code.
*   `backend/`: Contains the Python FastAPI backend code.
*   `README.md`: The main project README file.
