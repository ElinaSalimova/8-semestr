library('shiny')       # загрузка пакетов
library('lattice')
library('plyr')
library('data.table')

file.URL <- 'https://raw.githubusercontent.com/ElinaSalimova/8-semestr/laba3/laba3.csv'
download.file(file.URL, destfile = 'TV.csv')

df <- data.table(read.csv('TV.csv', 
                          stringsAsFactors = F))

shinyServer(function(input, output) {
    # текст для отображения на главной панели
    output$ds.text <- renderText({
      paste0('Вы выбрали разрешение: ',
             input$ds.to.plot
             )})
    output$ds.text1 <- renderText({
      paste0('Вы выбрали оценку с ',
             input$Stars.range[1], ' по ', input$Stars.range[2]
             )})
    output$ds.text2 <- renderText({
      paste0('Вы выбрали диагональ(в дюймах) с ',
             input$Diagonal.range[1], ' по ', input$Diagonal.range[2]
             )
    })
    output$ds.text3 <- renderText({
      paste0('Всего телевизоров - ', nrow(df)
      )
    })
    # строим гистограммы переменных
    output$ds.hist <- renderPlot({
        # сначала фильтруем данные
        DF <- df[df$Description == input$ds.to.plot, 1:8]
        DF <- DF[between(DF$Stars, input$Stars.range[1], input$Stars.range[2])]
        DF <- DF[between(DF$Diagonal.inch., input$Diagonal.range[1], input$Diagonal.range[2])]
        
    output$ds.text4 <- renderText({
      paste0('Отобранных телевизоров - ', nrow(DF)
             )
      })

        # затем строим график
        histogram( ~ Price..rub., 
                   data = DF,
                   xlab = '',
                  breaks = seq(min(df$Price..rub.), max(df$Price..rub.), 
                               length = input$int.hist + 1)
                   )
    })
})
