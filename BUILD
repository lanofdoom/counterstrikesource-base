load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_layer", "container_push")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

package(default_visibility = ["//visibility:public"])

#
# Counter-Strike: Source Binary
#

container_run_and_extract(
    name = "counter_strike_source",
    extract_file = "/tarball.tar.gz",
    commands = [
        "/opt/steam/steamcmd.sh +login anonymous +force_install_dir /opt/game +app_update 232330 validate +quit",
        "rm -rf /opt/game/steamapps",
        "chown -R nobody:root /opt/game",
        "tar -czvf /tarball.tar.gz /opt/game/",
    ],
    image = "@steamcmd_base//image",
)

#
# Server Image
#

download_pkgs(
    name = "server_deps",
    image_tar = "@ubuntu//image",
    packages = [
        "lib32gcc1",
    ],
)

install_pkgs(
    name = "server_base",
    image_tar = "@ubuntu//image",
    installables_tar = ":server_deps.tar",
    installation_cleanup_commands = "rm -rf /var/lib/apt/lists/*",
    output_image_name = "server_base",
)

container_image(
    name = "server_image",
    user = "nobody",
    entrypoint = ["/opt/game/srcds_run", "-game cstrike", "+map de_dust2", "-strictbindport"],
    base = "server_base.tar",
    tars = [
        ":counter_strike_source/tarball.tar.gz",
    ],
)

container_push(
   name = "push_server_image",
   image = ":server_image",
   format = "Docker",
   registry = "ghcr.io",
   repository = "lanofdoom/counterstrikesource-base/counterstrikesource-base",
   tag = "latest",
)