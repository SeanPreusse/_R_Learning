



train = read.csv("train.csv")
attach(train)
head(train)



# Predict Age

age.model = lm(age ~ fare + as.factor(title) + sibsp + parch)
for(i in 1:nrow(train)){
  if(is.na(train[i,"age"])){
    train[i,"age"] = predict(age.model, newdata = train [i,])
    }
}

write.csv(train, "train data with estimated age.csv")



# Logistic Regression

train = read.csv("train data with estimated age.csv")
attach(train)
#model with some interactions
model = glm(survived ~ pclass + fare + sibsp + parch + sex + age + pclass:sex + age:sex + sibsp:sex, family = binomial(link = "logit"))

# + as.factor(Title)
#modelling pclass as a factor has no impact on the results
#embarked reduced the model fit
summary(model)


predict(model, newdata=train)
#by default, the predict function gives the logit
#to transform into the probability, do the following transformation
#exp(predict(mode,, newdata=train)) /
#   (1+exp(predict(model, newdata=train)))

?predict.glm

# or specify the type = "response" argument
predict(model, newdata=train, type = "response")
#compare predictions to what you'd expect from the data
head(train)




# See how well you did in predicting the
# training set data
#model predictions for the training data
P =  predict(model, newdata=train, type = "response")
p.survive = round(P)

#install.packages("e1071")
#require(e1071)
#install.packages("caret")
require(caret)
confuctionMatrix(p.survive,survived)

#could else use cross validation to determine the accuracy of
#your model
#your in-sample prediction gives an ovverly optimistic estimate
#of te model accuracy
#because the model was estimated with that data




#make predictions using the test set
test.data = read.csv("test.csv")



#predict the missing values for age

age.model = lm(age ~ fare + as.factor(title) + sibsp + parch)

for(i in 1:nrow(test.data)){
  if(is.na(test.data[i,"age"])){
    test.data[i,"age"] = predict(age.model, newdata = test.data [i,])
  }
}


#in the test data set, the fare for the 153rd observation is missing
#estimate it as the mean of the third class:
test.data$fare[153]=mean(with(test.data, subset(fare, pclass==3)),
                         na.rm=TRUE)



#predictions for the test data set: If you want to
#specify a custom cutoff
#that's kind of missing with the data
predict(model, test.data)
p.survive=rep(NA, nrow(test.data))
for(i in 1:nrow(test.data)){
  P=predict(model, newdata=test.data[i,], type = "response")
#changing this value with give you different predictions!
if(P <= 0.5){
p.survive[i] = 0
}
  else{
    p.survive[i] = 1
  }
}


#otherwise, just use the round function to assign zeros and ones
p.survive = round(predict(model, newdata=test.data, type="response"))
head(p.survive, n=100)


data= data.frame(PassengerId =1:nrow(test.data), survived=p.survive)

write.table(data, "submission.csv", row.names=FALSE)




p.stress

names(p.stress) <- "predict"

write.table(test, "stress.test.csv", sep=",")










