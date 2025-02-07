library(pracma)
library(progress)
library(foreach)
library(doParallel)

vip_null_R <- function(x, y, perm, lv_for_vip) {
    m <- nrow(y)
    n <- ncol(y)
    tmp1 <- matrix(0, ncol(x), perm)

    #print("VIPNULL BEFORE LOOP")
    for (i in 1:perm) {
        source("/pipeline/workflow/scripts/scNOVA_scripts/script_PLSDA/pls_R_scNOVA.R")
        source("/pipeline/workflow/scripts/scNOVA_scripts/script_PLSDA/vip_R_v2_scNOVA.R")
        ind <- sample(m, m, replace = FALSE)
        #print("VIPNULL LOOP FLAG A - after ind")
        X1_r <- x[ind, ]
        result_pls_rand <- pls_R(X1_r, y, lv_for_vip)
        #print("VIPNULL LOOP FLAG B - after result_pls_rand")


        w <- data.matrix(result_pls_rand$pls_w)[, 1:lv_for_vip]
        r2 <- data.matrix(result_pls_rand$pls_ssq)[1:lv_for_vip, 4]
	#print(paste0("VIPNULL W  NCOL: ", ncol(w)))
	#print(paste0("VIPNULL W  NROW: ", nrow(w)))
	#print(paste0("VIPNULL R2 NCOL: ", ncol(r2)))
	#print(paste0("VIPNULL R2 NROW: ", nrow(r2)))
        result_vip_rand <- vip_R_v2(w, r2)
        #print("VIPNULL LOOP FLAG C - after result_vip_rand")
        tmp1[, i] <- result_vip_rand
        #print("VIPNULL LOOP FLAG D - after tmp assignment")
        # cat(paste0(i, ' '))
    }
    #print("VIPNULL AFTER LOOP")
    tmp1 <- Reshape(tmp1, ncol(x) * perm, 1)
    #print("VIPNULL OUT")
    return(tmp1)
}



#vip_null_R <- function(x, y, perm, lv_for_vip) {
#    print("IN VIPNULL")
#    m <- nrow(y)
#    n <- ncol(y)
#    print(paste0("m: ", m))
#    print(paste0("n: ", n))
#    print(paste0("lv_for_vip: ", lv_for_vip))
#    tmp1 <- matrix(0, ncol(x), perm)
#
#    opts <- list(progress = "text", verbose = FALSE)
#
#    cl <- makeCluster(64, outfile = "cluster_vip_null_R.log")
#    registerDoParallel(cl)
#    print("VIPNULL FLAG 0")
#
#    tmp1 <- foreach(i = 1:perm, .combine = "cbind", .packages = c("pracma"), .options.snow = opts) %dopar% {
#        source("/pipeline/workflow/scripts/scNOVA_scripts/script_PLSDA/pls_R_scNOVA.R")
#        source("/pipeline/workflow/scripts/scNOVA_scripts/script_PLSDA/vip_R_v2_scNOVA.R")
#	print("VIPNULL FLAG A0")
#        ind <- sample(m, m, replace = FALSE)
#	print("VIPNULL FLAG A")
#        X1_r <- x[ind, ]
#        result_pls_rand <- pls_R(X1_r, y, lv_for_vip)
#
#        w <- data.matrix(result_pls_rand$pls_w[, 1:lv_for_vip])
#        r2 <- data.matrix(result_pls_rand$pls_ssq[1:lv_for_vip, 4])
#	print("VIPNULL FLAG B: W R2 GEN")
#        result_vip_rand <- vip_R_v2(w, r2)
#        result_vip_rand
#	print("VIPNULL FLAG C")
#    } #-> tmp1
#
#    # Stop the parallel backend
#    stopCluster(cl)
#
#    tmp1 <- Reshape(tmp1, ncol(x) * perm, 1)
#    print("VIPNULL FLAG D")
#    return(tmp1)
#}
