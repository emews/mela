# Utility code to transform elements to strings and vice versa
elements_to_string <- function(x){
  paste0(x,collapse = ",")
}

elements_of_elements_to_string <- function(x){
  paste0(sapply(x,elements_to_string),collapse = ';')
}

list_to_string <- function(x){
  toString(x)
}

elements_of_lists_to_string <- function(x){
  paste0(sapply(x,list_to_string),collapse = ';')
}

string_to_list_of_vectors <- function(x){
  lapply(unlist(strsplit(x,";")),function(y) as.numeric(unlist(strsplit(y,","))))
}

# For a result element, res_element, append user extras if they exist
append_extras_if_exist <- function(res_element,x){
  if (length(x) > 1){
    res_element = c(res_element, list(user.extras = as.list(x[-1])))
  }
  res_element
}

result_with_extras_if_exist <- function(res,time_value){
  lapply(res, function(x) append_extras_if_exist(c(list(y=x[1]),
                                                   list(time=time_value)),x))
}