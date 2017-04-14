
export <- FALSE

##################

colns <- c("Experiment", "FullTrainAcc", "FullTrainKappa", "FullCvAcc", "FullCvKappa", "ReducedTrainAcc", "ReducedTrainKappa", "ReducedCvAcc", "ReducedCvKappa")
colnss <- c("Corpus", "Filters", "Attribute", "Topics", "FullTrainAcc", "FullTrainKappa", "FullCvAcc", "FullCvKappa", "ReducedTrainAcc", "ReducedTrainKappa", "ReducedCvAcc", "ReducedCvKappa")

corpi <- c(rep("Gold",48), rep("Plus01",48), rep("Plus02",48), rep("Plus03",48), rep("Plus04",48), rep("Plus05",48), rep("Plus06",48), rep("Plus07",48), rep("Plus08",48), rep("Plus09",48), rep("Plus10",48))
filti <- rep(c(rep("1", 24), rep("2", 24)), 11)
attri <- rep(c(rep("Token", 8), rep("Lemma", 8), rep("LemPos", 8)), 22)

# ----------------------------------- #

gettops <- function(x) {
  substr(x, nchar(x)-1, nchar(x))
}

getexp <- function(x) {
  substr(x, 1, nchar(x)-3)
}

# ----------------------------------- #

cow <- read.table("~/Workingcopies/topics/results/cow.tsv", quote="\"", comment.char="")
colnames(cow) <- colns
cow <- cbind(corpi, filti, attri, unlist(lapply(as.character(cow$Experiment), gettops)), cow[,-1])
colnames(cow) <- colnss

dereko <- read.table("~/Workingcopies/topics/results/dereko.tsv", quote="\"", comment.char="")
colnames(dereko) <- colns
dereko <- cbind(corpi, filti, attri, unlist(lapply(as.character(dereko$Experiment), gettops)), dereko[,-1])
colnames(dereko) <- colnss

coreko <- read.table("~/Workingcopies/topics/results/coreko.tsv", quote="\"", comment.char="")
colnames(coreko) <- colns
coreko <- cbind(corpi[1:192], filti[1:192], attri[1:192], unlist(lapply(as.character(coreko$Experiment), gettops)), coreko[,-1])
colnames(coreko) <- colnss

# ----------------------------------- #

cow.max.kappa <- max(cow$ReducedCvKappa)
cow.max.kappa.idx <- which(cow$ReducedCvKappa == cow.max.kappa)
cow.best <- cow[cow.max.kappa.idx,]
cat("Web best:\n")
print(cow.best)

dereko.max.kappa <- max(dereko$ReducedCvKappa)
dereko.max.kappa.idx <- which(dereko$ReducedCvKappa == dereko.max.kappa)
dereko.best <- dereko[dereko.max.kappa.idx,]
cat("News best:\n")
print(dereko.best)

coreko.max.kappa <- max(coreko$ReducedCvKappa)
coreko.max.kappa.idx <- which(coreko$ReducedCvKappa == coreko.max.kappa)
coreko.best <- coreko[coreko.max.kappa.idx,]
cat("COReKo best:\n")
print(coreko.best)


# ----------------------------------- #

lwd=2
cex=1.2
cex2=1.6
leg=c("red. cat., eval. on training data", "all cat., eval. on training data", "red. cat., 10CV", "all cat., 10CV")

# ----------------------------------- #

if (export) pdf("cow.pdf", width=15)
par(mfrow=c(1,4))

# Gold.
offset=0*48
pname="Web (gold standard only)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2, cex.main=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 1.
offset=1*48
pname="Web (gold standard + 400 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 2.
offset=2*48
pname="Web (gold standard + 800 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 3.
offset=3*48
pname="Web (gold standard + 1,200 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}


if (export) dev.off()


# Plus 3.
offset=8*48
pname="Web (gold standard + 1,200 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}



# ----------------------------------- #


if (export) pdf("dereko.pdf", width=15)
par(mfrow=c(1,4))

# Gold.
offset=0*48
pname="News (gold standard only)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 1.
offset=1*48
pname="News (gold standard + 400 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 2.
offset=2*48
pname="News (gold standard + 800 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 3.
offset=3*48
pname="News (gold standard + 1,200 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()



# ----------------------------------- #


if (export) pdf("coreko.pdf", width=15)
par(mfrow=c(1,4))

# Gold.
offset=0*48
pname="Web+News (gold standard only)"
plot(NULL, xlim=c(1,8), ylim=c(40,90), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 1.
offset=1*48
pname="Web+News (gold standard + 800 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(40,90), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 2.
offset=2*48
pname="Web+News (gold standard + 1,600 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(40,90), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 3.
offset=3*48
pname="Web+News (gold standard + 2,400 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(40,90), xaxt="n", xlab="Number of topics", ylab="Accuracy", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()








# ----------------------------------- #

if (export) pdf("cow_kappa.pdf", width=15)
par(mfrow=c(1,4))

# Gold.
offset=0*48
pname="Web (gold standard only)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 1.
offset=1*48
pname="Web (gold standard + 400 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 2.
offset=2*48
pname="Web (gold standard + 800 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 3.
offset=3*48
pname="Web (gold standard + 1,200 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}


if (export) dev.off()

# ----------------------------------- #


if (export) pdf("dereko_kappa.pdf", width=15)
par(mfrow=c(1,4))

# Gold.
offset=0*48
pname="News (gold standard only)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 1.
offset=1*48
pname="News (gold standard + 400 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 2.
offset=2*48
pname="News (gold standard + 800 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 3.
offset=3*48
pname="News (gold standard + 1,200 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()

# ----------------------------------- #


if (export) pdf("coreko_kappa.pdf", width=15)
par(mfrow=c(1,4))

# Gold.
offset=0*48
pname="Web+News (gold standard only)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 1.
offset=1*48
pname="Web+News (gold standard + 800 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 2.
offset=2*48
pname="Web+News (gold standard + 1,600 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

# Plus 3.
offset=3*48
pname="Web+News (gold standard + 3,200 mix-in doc.)"
plot(NULL, xlim=c(1,8), ylim=c(0,1), xaxt="n", xlab="Number of topics", ylab="Kappa", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainKappa[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainKappa[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvKappa[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvKappa[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()

# For IDS Yearbook

#export <- TRUE
leg.de <- c("reduziert, Trainigsdaten", "komplett, Trainingsdaten", "reduziert, kreuzvalidiert", "komplett, kreuzvalidiert")

if (export) svg("idsyb_decow.svg")

# DECOW plus 3200.
offset=8*48
pname="DECOW (Goldstandard + 3,200 Dokumente)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Anzahl der Topiks", ylab="Genauigkeit", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg.de, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(cow$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(cow$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(cow$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(cow$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()

if (export) svg("idsyb_dereko.svg")

# DeReKo plus 3600.
offset=9*48
pname="DeReKo (Goldstandard + 3,600 Dokumente)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Anzahl der Topiks", ylab="Genauigkeit", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("bottomleft", legend = leg.de, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(dereko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(dereko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(dereko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(dereko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()

if (export) svg("idsyb_coreko.svg")

# DeReKo plus 3600.
offset=0*48
pname="DECOW + DeReKo (nur Goldstandard)"
plot(NULL, xlim=c(1,8), ylim=c(45,100), xaxt="n", xlab="Anzahl der Topiks", ylab="Genauigkeit", main=pname, cex.axis=cex2, cex.lab=cex2)
axis(1, at=1:8, labels=seq(20,90,10), cex.axis=cex2)
legend("topleft", legend = leg.de, col=c(2,1,4,3), lty=c(3,2,5,4), lwd=lwd, cex=cex)
for (i in seq(1+offset, 41+offset, 8)) {
  hi <- i+7
  lines(coreko$FullTrainAcc[i:hi], col=1, lty=2, lwd=lwd)
  lines(coreko$ReducedTrainAcc[i:hi], col=2, lty=3, lwd=lwd)
  lines(coreko$FullCvAcc[i:hi], col=3, lty=4, lwd=lwd)
  lines(coreko$ReducedCvAcc[i:hi], col=4, lty=5, lwd=lwd)
}

if (export) dev.off()