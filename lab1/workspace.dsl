workspace {

    !identifiers hierarchical

    model {
        properties { 
            structurizr.groupSeparator "/"
        }
        user = person "Пользователь"
        messenger = softwareSystem "Мессенджер" {

            user_service = container "Сервис для взаимодействия с пользователем" 
            ptp_service = container "PtP чат" 
            chat_service = container "Общий чат" 
            group "Слой данных"{
                user_db = container "User Data" {
                    description "База данных с пользователями"
                    technology "PostgreSQL"
                    tags "database"
                }
                ptp_db = container "PtP Data" {
                    description "PtP база данных"
                    technology "PostgreSQL"
                    tags "database"
                }
                chat_db = container "Chat Data" {
                    description "База данных общего чата"
                    technology "PostgreSQL"
                    tags "database"
                }
            }

        }
            
        user -> messenger "Вход пользователя в систему"

        user -> messenger.user_service "Вход пользователя в систему"
        
        messenger.user_service -> messenger.user_db "Поиск/Добавление пользователя"
        messenger.user_service -> messenger.ptp_service "Пользовательский запрос в PtP сервис"
        messenger.user_service -> messenger.chat_service "Пользовательский запрос в chat сервис"

        messenger.ptp_service -> messenger.ptp_db "Запрос на получение данных PtP чата"
        messenger.chat_service -> messenger.chat_db "Запрос на получение данных чата"
        
        // massanger.user_service.user_api -> massanger.user_db "Поиск/Добавление пользователя"
        // massanger.user_service.send_message_api -> messenger.ptp_service

        deploymentEnvironment "Deploy" {
            deploymentNode "Пользовательский Сервис" {
                containerInstance messenger.user_service
            }
            deploymentNode "PtP чат сервис" {
                containerInstance messenger.ptp_service
            }
            deploymentNode "Сервис для общего чата" {
                containerInstance messenger.chat_service
            }
            deploymentNode "БД пользователей" {
                containerInstance messenger.user_db
            }
            deploymentNode "БД PtP чата" {
                containerInstance messenger.ptp_db
            }
            deploymentNode "БД общего чата" {
                containerInstance messenger.chat_db
            }
        }

    }

    views {
        themes default
        
        systemContext messenger {
            include *
            autoLayout
        }

        container messenger {
            include *
            autoLayout
        }

        dynamic messenger "UC01" "Добавление нового пользователя" {
            autoLayout
            user -> messenger.user_service "Создать нового пользователя (POST /user)"
            messenger.user_service -> messenger.user_db "Добавить пользователя в базу, если его нету"
        }

        dynamic messenger "UC02" "Поиск пользователя по логину" {
            autoLayout
            user -> messenger.user_service "Найти пользователя по логину (GET /user)"
            messenger.user_service -> messenger.user_db "Найти пользователя в бд пользователей"
        }

        dynamic messenger "UC03" "Поиск пользователя по маске имя и фамилии" {
            autoLayout
            user -> messenger.user_service "Найти пользователя по маске (GET /user)"
            messenger.user_service -> messenger.user_db "Найти пользователя в бд пользователей"
        }

        dynamic messenger "UC11" "Создание группового чата" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Запрос на создание групового чата"
            messenger.chat_service -> messenger.chat_db "Создание групповогочата и сохранение в бд"
        }

            dynamic messenger "UC12" "Добавление пользователя в групповой чат" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Запрос на добавление пользователя в групповой чат"
            messenger.chat_service -> messenger.chat_db "Добавление пользователя в групповой чат"
        }

            dynamic messenger "UC13" "Добавление сообщения в групповой чат" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Запрос на добавление сообщения в групового чат"
            messenger.chat_service -> messenger.chat_db "добавление сообщения в групового чат"
        }

            dynamic messenger "UC14" "Загрузка сообщений группового чата" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service 
            messenger.chat_service -> messenger.chat_db "загрузка сообщения из бд"
        }

            dynamic messenger "UC21" "Отправка PtP Сообщений пользователю" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service 
            messenger.chat_service -> messenger.chat_db 
        }

            dynamic messenger "UC22" "получение PtP списка сообщения для пользователя" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service 
            messenger.chat_service -> messenger.chat_db "Получение PtP списка"
        }

        deployment messenger "Deploy" "deployment" {
             include *
             autoLayout
        }
        styles {
            element "database" {
                shape cylinder
                background #77ff44
                color #000000
            }
        }
    }

}