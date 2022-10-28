#these vars are specific to this environment
#for stage account often the vars are just in the variables.tf

#website vars
website_hosted_zone = "www-stage.thedataescaperoom.com"
website_route53_domains = ["www-stage.thedataescaperoom.com"]
website_externally_managed_domains = ["stage.thedataescaperoom.com"]
website_acm_domain_name = "stage.thedataescaperoom.com"

#game vars
admin_cms_domain_name = "admin.dungeon-stage.thedataescaperoom.com"
dungeon_domain_name = "dungeon-stage.thedataescaperoom.com"
