module "jenkins_oidc" {
  source = "../../"

  role_name = "jenkins"
  url       = "https://jenkins.example.com/oidc"

  # Only tokens minted for jobs under this folder may assume the role
  # (sub = Jenkins job URL with the oidc-provider plugin defaults).
  allowed_subject_patterns = [
    "https://jenkins.example.com/job/my-org/job/my-repo/job/*"
  ]
}
