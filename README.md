# GithubRepos

Приложение для поиска репозиториев GitHub с возможностью сохранения в избранное.

## Технологии

- Swift
- SwiftUI
- Combine
- Async/await
- SwiftData
- Clean Architecture

## Особенности

- **Поиск репозиториев**: Интеграция с GitHub API для поиска репозиториев
- **Умная пагинация**: Автоматическая подгрузка результатов при прокрутке
- **Локальное хранение**: Возможность сохранять избранные репозитории
- **Кастомное управление списком избранного**: 
  - Drag-and-drop для изменения порядка
  - Свайп-действия для редактирования и удаления
  - Гибкая сортировка (по дате, имени, звездам)
- **Адаптивный интерфейс**: Динамическая высота ячеек в зависимости от контента
- **Onboarding**: Интуитивное обучение новых пользователей
- **Оффлайн-режим**: Доступ к сохраненным репозиториям без интернета

## Архитектурные решения

- **Clean Architecture**: Четкое разделение на слои Data, Domain и Presentation
- **MVVM**: Использование ViewModel для бизнес-логики
- **Unit Testing**: Покрытие ключевой функциональности тестами
- **SwiftData**: Локальное хранение данных