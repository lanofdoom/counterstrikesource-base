load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

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
# Build Image With i386 Enabled
#

container_run_and_extract(
    name = "enable_i386_sources",
    image = "@ubuntu//image",
    extract_file = "/var/lib/dpkg/arch",
    commands = [
        "dpkg --add-architecture i386",
    ],
)

container_image(
    name = "ubuntu_with_i386_packages",
    base = "@ubuntu//image",
    directory = "/var/lib/dpkg",
    files = [
        ":enable_i386_sources/var/lib/dpkg/arch",
    ],
)

#
# Server Image
#

download_pkgs(
    name = "server_deps",
    image_tar = ":ubuntu_with_i386_packages.tar",
    packages = [
        "lib32gcc1",
        # TODO: Put these back in counterstrikesource-server whenever Bazel's
        #       build size issues are worked out.
        "ca-certificates:i386",
        "libcurl4:i386",
    ],
)

install_pkgs(
    name = "server_base",
    image_tar = ":ubuntu_with_i386_packages.tar",
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