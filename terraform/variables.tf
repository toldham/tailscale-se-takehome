#### GENERAL PROJECT VARIABLES ####

variable "region" {
    type = string
}

variable "project_id" {
    type = string
} 

variable "project_name" {
    type = string
}

variable "env" {
    type = string
}

#### VPC Network ####

variable "vpc_name" {
    type = string
}

variable "vpc_subnet_name" {
    type = string
}

variable "vpc_subnet_range" {
    type = string
}