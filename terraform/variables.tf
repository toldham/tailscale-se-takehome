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

variable "zone" {
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

#### Compute VM ####

variable "vm_name" {
    type = string
}

variable "vm_name_ssh" {
    type = string
}

variable "vm_machine_type" {
    type = string
}

variable "vm_hostname" {
    type = string
}

variable "vm_hostname_ssh" {
    type = string
}

variable "vm_image" {
    type = string
}

variable "vm_architecture" {
    type = string
}

variable "vm_tailscale_api_auth" {
    type = string
    sensitive = true
}