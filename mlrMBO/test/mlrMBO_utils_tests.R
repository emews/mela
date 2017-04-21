# run with test_file("mlrMBO_utils_tests.R")
require(testthat)

test_that("list_to_string works",{
  l = list(x1 = -4.5, x2 = 6.3)
  expected_string = "-4.5, 6.3"
  result_string = list_to_string(l)
  # print(result_string)
  expect_equal(expected_string,result_string)
})

test_that("elements_of_lists_to_string works",{
  l1 = list(x1 = -4.5, x2 = 6.3)
  l2 = list(x1 = 7.6, x2 = 0.3)
  l3 = list(l1,l2)
  expected_string = "-4.5, 6.3;7.6, 0.3"
  result_string = elements_of_lists_to_string(l3)
  # print(result_string)
  expect_equal(expected_string,result_string)
})

test_that("append_extras_if_exist works",{
  x = c(1,2,3)
  res_element = list(y = 1, time = 2.3)
  new_res_element = append_extras_if_exist(res_element,x)
  expected_res_element = list(y = 1, time = 2.3, user.extras = list(2,3))
  # print(new_res_element)
  expect_equal(expected_res_element,new_res_element, info = "length(x) > 1")

  x = c(3)
  res_element = list(y = 3, time = 2.3)
  new_res_element = append_extras_if_exist(res_element,x)
  expected_res_element = list(y = 3, time = 2.3)
  # print(new_res_element)
  expect_equal(expected_res_element,new_res_element, info = "length(x) == 1")
})

test_that("result_with_extras_if_exist works",{
  list_of_vectors = list(c(1,2,3),c(4,5,6),c(7,8,9))
  new_res = result_with_extras_if_exist(list_of_vectors,4.5)
  expected_res = list(list(y = 1, time = 4.5, user.extras = list(2,3)),
                      list(y = 4, time = 4.5, user.extras = list(5,6)),
                      list(y = 7, time = 4.5, user.extras = list(8,9)))
  # print(new_res_element)
  expect_equal(expected_res,new_res, info = "length(x) > 1, uniform")

  list_of_vectors = list(c(1,2,3),c(4,6),c(7))
  new_res = result_with_extras_if_exist(list_of_vectors,4.5)
  expected_res = list(list(y = 1, time = 4.5, user.extras = list(2,3)),
                      list(y = 4, time = 4.5, user.extras = list(6)),
                      list(y = 7, time = 4.5))
  # print(new_res_element)
  expect_equal(expected_res,new_res, info = "length(x) mixed")

  list_of_vectors = list(c(1),c(4),c(7))
  new_res = result_with_extras_if_exist(list_of_vectors,4.5)
  expected_res = list(list(y = 1, time = 4.5),
                      list(y = 4, time = 4.5),
                      list(y = 7, time = 4.5))
  # print(new_res_element)
  expect_equal(expected_res,new_res, info = "length(x) == 1")
})
