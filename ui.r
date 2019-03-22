library('shiny')       # загрузка пакетов
library('data.table')

file.URL <- 'https://raw.githubusercontent.com/ElinaSalimova/8-semestr/laba3/laba3.csv'
download.file(file.URL, destfile = 'TV.csv')

df <- data.table(read.csv('TV.csv', 
                          stringsAsFactors = F))


ds.filter <- as.character(unique(df$Description))
names(ds.filter) <- ds.filter
ds.filter <- as.list(ds.filter)

tr.filter <- as.character(unique(df$USB))
names(tr.filter) <- tr.filter
tr.filter <- as.list(tr.filter)

# размещение всех объектов на странице
shinyUI(
    # создать страницу с боковой панелью
    # и главной областью для отчётов
    pageWithSidebar(
        # название приложения:
        headerPanel('Список телевизоров на яндекс маркете'),
        # боковая панель:
        sidebarPanel(
            selectInput(
                'ds.to.plot',
                        'Выберите разрешение',
                        ds.filter),
            sliderInput('Stars.range', 'Оценка:',
                        min = min(df$Stars), max = max(df$Stars), value = c(min(df$Stars), max(df$Stars))),           
            
            sliderInput('Diagonal.range', 'Диагональ в дюймах:',
                        min = min(df$Diagonal.inch.), max = max(df$Diagonal.inch.), value = c(min(df$Diagonal.inch.), max(df$Diagonal.inch.))),
            sliderInput(               # слайдер: кол-во интервалов гистограммы
              'int.hist',                       # связанная переменная
              'Количество интервалов гистограммы:', # подпись
              min = 2, max = 10,                    # мин и макс
              value = floor(1 + log(50, base = 2)), # базовое значение
              step = 1)                             # шаг
        ),
        # главная область
        mainPanel(
            # текстовый объект для отображения
            textOutput('ds.text'),
            textOutput('ds.text1'),
            textOutput('ds.text2'),
            textOutput('ds.text3'),
            textOutput('ds.text4'),
            # гистограммы переменных
            plotOutput('ds.hist')
            )
        )
    )
