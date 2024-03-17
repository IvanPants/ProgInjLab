workspace {

    !identifiers hierarchical

    model {
        properties { 
            structurizr.groupSeparator "/"
        }
        user = person "Пользователь"
        messenger = softwareSystem "Мессенджер" {

            user_service = container "Сервис для взаимодействия с пользователем"
            identify_user = container "Сервис для определения пользователя" 
                description "Сервия для работы с данными пользователя (БД/КЕШ)"
            
            ptp_service = container "PtP чат" 
            chat_service = container "Общий чат" 

            group "Слой данных"{
                user_db = container "User Data" {
                    description "База данных с пользователями"
                    technology "PostgreSQL"
                    tags "database"
                }
                user_cash = container "cache" {
                description "Кеш пользовательских данных"
                technology "PostgreSQL"
                tags "cache"
                }
                ptp_db = container "PtP Data" {
                    description "PtP база данных"
                    technology "MongoDB"
                    tags "database"
                }
                chat_db = container "Chat Data" {
                    description "База данных общего чата"
                    technology "MongoDB"
                    tags "database"
                }
            }

        }
            
        user -> messenger "Подключение пользователя к сервису"

        user -> messenger.user_service "Подключение пользователя к сервису"
        
        messenger.user_service -> messenger.identify_user "Пользовательский запрос"
        messenger.identify_user -> messenger.user_db "Поиск/Добавление пользователя"
        messenger.identify_user -> messenger.user_cash "Поиск в кеше"
        messenger.user_service -> messenger.ptp_service "Пользовательский запрос в PtP сервис"
        messenger.user_service -> messenger.chat_service "Пользовательский запрос в chat сервис"
        messenger.ptp_service -> messenger.ptp_db "Запрос на получение данных PtP чата"
        messenger.chat_service -> messenger.chat_db "Запрос на получение данных чата"
        

        deploymentEnvironment "Deploy" {
            deploymentNode "Пользовательский Сервис" {
                containerInstance messenger.user_service
            }
            deploymentNode "Сервис для определения пользователя" {
                containerInstance messenger.identify_user
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
            deploymentNode "Кеш" {
                containerInstance messenger.user_cash
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
            messenger.user_service -> messenger.identify_user "проверяем свободин ли логин"
            messenger.identify_user -> messenger.user_db "Занести данные в бд"
            messenger.identify_user -> messenger.user_cash "Занести данные в кеш"
        }

        dynamic messenger "UC02" "Поиск пользователя по логину" {
            autoLayout
            user -> messenger.user_service "Найти пользователя по логину (GET /user)"
            messenger.user_service -> messenger.identify_user 
            messenger.identify_user -> messenger.user_cash "Найти пользователя в кеше"
            messenger.identify_user -> messenger.user_db "Если пользователь не найден в кеше, Найти пользователя в бд"
        }

        dynamic messenger "UC03" "Поиск пользователя по маске имя и фамилии" {
            autoLayout
            user -> messenger.user_service "Найти пользователя по маске (GET /user)"
            messenger.user_service -> messenger.identify_user 
            messenger.identify_user -> messenger.user_cash "Найти пользователя в кеше"
            messenger.identify_user -> messenger.user_db "Если пользователь не найден в кеше, Найти пользователя в бд"
        }

        dynamic messenger "UC11" "Создание группового чата" {
            autoLayout
            user -> messenger.user_service 
            messenger.user_service -> messenger.chat_service "Создать чат (POST /users_chat)"
            messenger.chat_service -> messenger.chat_db "Cохраненить чат в бд"
        }

            dynamic messenger "UC12" "Добавление пользователя в групповой чат" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Добавление пользователя в груповой чат (POST /user/users_chat)"
            messenger.chat_service -> messenger.chat_db "Сохранить изменения в бд"
        }

            dynamic messenger "UC13" "Добавление сообщения в групповой чат" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Если пользователь есть в чате, добавить сообщение в груповой чат (POST user/user_chat/message)"
            messenger.chat_service -> messenger.chat_db "Сохранить в БД"
        }

            dynamic messenger "UC14" "Загрузка сообщений группового чата" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Поиск сообщений чата (GET user/user_chat/message)"
            messenger.chat_service -> messenger.chat_db "загрузка сообщений из бд"
        }

            dynamic messenger "UC21" "Отправка PtP Сообщений пользователю" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Если пользователь есть в PtP чате, добавить сообщение в груповой чат (POST user/ptp_chat/message)"
            messenger.chat_service -> messenger.chat_db "Сохранить в бд"
        }

            dynamic messenger "UC22" "получение PtP списка сообщения для пользователя" {
            autoLayout
            user -> messenger.user_service "Аунтификация пользователя"
            messenger.user_service -> messenger.chat_service "Поиск сообщений чата (GET user/ptp_chat/message)"
            messenger.chat_service -> messenger.chat_db "загрузка сообщений из бд"
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
        styles {
            element "cache" {
            shape cylinder
            background #CDFF44
            color #000000
            }

        }
    }

}