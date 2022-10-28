#these vars are specific to this environment
#for int account often the vars are just in the variables.tf

#website vars
website_hosted_zone = "www-int.thedataescaperoom.com"
website_route53_domains = ["www-int.thedataescaperoom.com"]
website_externally_managed_domains = ["int.thedataescaperoom.com"]
website_acm_domain_name = "int.thedataescaperoom.com"

#game vars
admin_cms_domain_name = "admin.dungeon-int.thedataescaperoom.com"
dungeon_domain_name = "dungeon-int.thedataescaperoom.com"

