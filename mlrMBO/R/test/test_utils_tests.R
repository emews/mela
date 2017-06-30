#Run using test_file, test_dir

require(testthat)
source("test_utils.R")

test_that("split.into.param.lines works",{
  input <- "1,2,3,4;5,6,7,8"
  expected_parms <- list(1:4,5:8)
  res <- split.into.param.lines(input)
  expect_equal(res, expected_parms)
})

test_that("make.into.q.res works",{
  input <- list(3.4,6.7)
  expected_res <- "3.4;6.7"
  res <- make.into.q.res(input)
  expect_equal(expected_res, res)
})

test_that("split.json.into.param.lines works",{
  input <- "{\"a\": 1, \"b\": 2, \"c\":3, \"d\":4};{\"a\":5,\"b\":6,\"c\":7,\"d\":8}"
  expected_parms <- c(1,2)
  res <- split.json.into.dummy.param.lines(input)
  expect_equal(res, expected_parms)
})
