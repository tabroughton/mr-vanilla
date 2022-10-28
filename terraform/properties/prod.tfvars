#these vars are specific to this environment
#for prod account often the vars are just in the variables.tf

#website vars
website_hosted_zone = "www.thedataescaperoom.com"
website_route53_domains = ["www.thedataescaperoom.com"]
website_externally_managed_domains = ["thedataescaperoom.com"]
website_acm_domain_name = "thedataescaperoom.com"

#game vars
admin_cms_domain_name = "admin.dungeon.thedataescaperoom.com"
dungeon_domain_name = "dungeon.thedataescaperoom.com"
