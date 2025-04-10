# Project Resources
# Now we can manage project resources properly using the module outputs

# PAUSATF Project Resources
resource "digitalocean_project_resources" "pausatf_resources" {
  project = module.project_pausatf.id
  resources = [
    module.droplet_pausatf_org.urn,
    module.droplet_pausatforg_primary.urn,
    module.domain_pausatf_internal.domain_urn,
    module.domain_pausatf_steelhouselabs_com.domain_urn,
    module.domain_pausatf_tacklebox_io.domain_urn
  ]
}

# Relenz Project Resources
resource "digitalocean_project_resources" "relenz_resources" {
  project = module.project_relenz.id
  resources = [
    module.domain_nbdonate_org.domain_urn,
    module.domain_tacklebox_io.domain_urn,
    module.domain_tantalum_io.domain_urn
  ]
}

# Paws That Matter Project Resources
resource "digitalocean_project_resources" "paws_that_matter_resources" {
  project = module.project_paws_that_matter.id
  resources = [
    module.domain_pupznpalz_dev.domain_urn
  ]
}

# Rescue System Project Resources
# Currently no resources are associated with this project
resource "digitalocean_project_resources" "rescue_system_resources" {
  project = module.project_rescue_system.id
  resources = []
}
