# загрузка пакетов ----
library('dplyr')
library('data.table')          # работаем с объектами "таблица данных"
library('moments')             # коэффициенты асимметрии и эксцесса 
library('lattice')
library('ggplot2')

# загружаем файл с данными по импорту масла в РФ (из прошлой практики) ----
fileURL <- 'https://raw.githubusercontent.com/aksyuk/R-data/master/COMTRADE/040510-Imp-RF-comtrade.csv'
# создаём директорию для данных, если она ещё не существует:
if (!file.exists('./data')) {
  dir.create('./data')
}
# создаём файл с логом загрузок, если он ещё не существует:
if (!file.exists('./data/download.log')) {
  file.create('./data/download.log')
}
# загружаем файл, если он ещё не существует,
#  и делаем запись о загрузке в лог:
if (!file.exists('./data/040510-Imp-RF-comtrade.csv')) {
  download.file(fileURL, './data/040510-Imp-RF-comtrade.csv')
  # сделать запись в лог
  write(paste('Файл "040510-Imp-RF-comtrade.csv" загружен', Sys.time()), 
        file = './data/download.log', append = T)
}
# читаем данные из загруженного .csv во фрейм, если он ещё не существует
if (!exists('DT')){
  DT.import <- data.table(read.csv('./data/040510-Imp-RF-comtrade.csv', 
                                   stringsAsFactors = F))
}
# предварительный просмотр ----
dim(DT.import)            # размерность таблицы
str(DT.import)            # структура (характеристики столбцов)
DT.import          # удобный просмотр объекта data.table

unique(DT.import$Reporter)
unique(DT.import$Period)
DT.import$Period <- as.character(DT.import$Period)

# фильтр ----
DT.import <- data.table(filter(DT.import, startsWith(Period, "2013")))

# сколько NA в каждом из оставшихся столбцов?
na.num <- apply(DT.import, 2, function(x) length(which(is.na(x))))

# выводим только положительные и по убыванию
sort(na.num[na.num > 0], decreasing = T)
# заменяем пропуски на модельные
x <- DT.import$Trade.Value.USD
y <- DT.import$Netweight.kg
y[y == 0] <- NA
# оценка регрессии с помощью МНК
fit <- lm(y ~ x)
# координаты пропущенных y по оси x
NAs <- x[is.na(y)]
y[is.na(y)] <- predict(fit, newdata = data.frame(x = NAs))
head(DT.import)

#Эмбарго 2014
Embargo <- c("Lithuania", "Ukraine", "EU-27", "Russian Federation")
#Остальные страны
ROTW <- c("Azerbaijan", "Armenia", "Belarus", "Georgia", "Germany", "Slovenia")

#ключевое поле ----
setkey(DT.import, Reporter)
#3 отдельных таблицы
DT.import.Embargo <- DT.import[Embargo]
DT.import.ROTW <- DT.import[ROTW]
#принадлежность к группам стран
DT.import1 <- mutate(DT.import.Embargo, country_factor = 'Embargo')
DT.import2 <- mutate(DT.import.ROTW, country_factor = 'ROTW')
#объединение таблиц
DT.import <- data.table()
DT.import <- full_join(DT.import1, DT.import2)


#считаем суммарные постаки по годам и союзу
res <- select(DT.import, Netweight.kg, country_factor,Period.Desc) %>%
  group_by(country_factor, Period.Desc)
res1 <- na.omit(res)

#фактор по 2 группам стран
years <- as.factor(unique(res1$country_factor))

# Пакет "base" ----

#нужна палитра из 2 цветов
cls <- palette(rainbow(2))

# КОРОБЧАТАЯ ДИАГРАММА
# ящики с усами по месяцам
png('Pic-01.png', width = 500, height = 500)
par(mfrow=c(1,2))
boxplot(DT.import1$Netweight.kg ~ as.factor(DT.import1$Period.Desc), data=DT.import1,
        xlab = 'Месяц',
        ylab = 'Суммарные поставки',
        main = 'пакет base Embargo',
        col = cls[1]
        
)



boxplot(DT.import2$Netweight.kg ~ as.factor(DT.import2$Period.Desc), data=DT.import2,
        xlab = 'Месяц',
        ylab = 'Суммарные поставки',
        main = 'пакет base ROTW',
        col = cls[2]
)
dev.off()

# Пакет "lattice" ----
# КОРОБКИ ПО ГРУППАМ
png('Pic-02.png', width = 500, height = 500)
bwplot(res1$Netweight.kg ~ as.factor(res1$Period.Desc) | res1$country_factor, data=res1,
       xlab = 'Месяц',
       ylab = 'Суммарные поставки',
       main = 'пакет lattice',
       scales=list(x=list(rot=90))
       
)

dev.off()

# Пакет "ggplot2" ----

# КОРОБКИ ПО ГРУППАМ (ЦВЕТ + ОСЬ)
# всё, что зависит от значений данных, заносим в аргумент aes
png('Pic-03.png', width = 500, height = 500)
gp <- ggplot(data = res1, aes(x = as.factor(res1$Period.Desc),
                              y = res1$Netweight.kg,
                              color = res1$country_factor)
             
)
gp <- gp + geom_boxplot()
gp <- gp + xlab('Месяц')
gp <- gp + ylab('Суммарные поставки') + theme(axis.text.x = element_text(angle = 90, hjust = 1))
gp

dev.off()
