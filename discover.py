#!/usr/bin/env python
"""Discover cmeel packages on Github."""

import argparse
import logging
import os
from base64 import b64decode
from dataclasses import dataclass
from pprint import pprint
from tomllib import loads

import graphviz
import httpx

API = "https://api.github.com"
ORGS = [
    "cmake-wheel",
    "simple-robotics",
]
LOG = logging.getLogger("cmeel.meta.discover")


def dotget(data, key, default):
    """get key in data or default."""
    for part in key.split("."):
        if part in data:
            data = data[part]
        else:
            return default
    return data


@dataclass
class Pkg:
    source: str
    name: str
    version: str
    deps: [str]
    build_deps: [str]
    any: bool
    pyver: bool
    py3: bool

    def __str__(self):
        return "\n".join([self.name, self.version, self.special()]).strip()

    def special(self) -> str:
        if self.any:
            return "any"
        if self.pyver:
            return "pyver"
        if self.py3:
            return "py3"
        return ""

    @staticmethod
    def from_pyproject(source, pyproject):
        def parse_dep(d: str) -> str:
            return d.split(" ")[0].split("[")[0].split("=")[0]

        build_deps = [parse_dep(d) for d in pyproject["build-system"]["requires"]]
        deps = (
            [parse_dep(d) for d in pyproject["project"]["dependencies"]]
            if "dependencies" in pyproject["project"]
            else []
        )
        return Pkg(
            source=source,
            name=pyproject["project"]["name"],
            version=pyproject["project"]["version"],
            deps=deps,
            build_deps=build_deps,
            any=dotget(pyproject, "tool.cmeel.any", False),
            pyver=dotget(pyproject, "tool.cmeel.pyver-any", False),
            py3=dotget(pyproject, "tool.cmeel.py3-none", False),
        )


def main(token, orgs):
    LOG.debug(f"main {token=} {orgs=}")
    headers = {"Authorization": f"Bearer {token}"}
    repos = []
    for org in orgs:
        page = 1
        while page:
            resp = httpx.get(
                f"{API}/orgs/{org}/repos", params={"page": page}, headers=headers
            )
            if resp.status_code != 200:
                LOG.error(f"Can't get {org} repos page {page}: {resp}")
                continue
            if not resp.json():
                LOG.info(f"{org} repos page {page} is empty")
                page = False
                continue
            for repo in resp.json():
                if repo["visibility"] != "public":
                    LOG.info(f"ignoring non public repo: {repo['name']}")
                    continue
                if repo["archived"]:
                    LOG.info(f"ignoring archived repo: {repo['name']}")
                    continue
                url = repo["contents_url"].replace("{+path}", "pyproject.toml")
                resp = httpx.get(url, headers=headers)
                if resp.status_code != 200:
                    LOG.info(f"Can't get {url}: {resp}")
                    continue
                pyproject = loads(b64decode(resp.json()["content"]).decode())
                if "build-system" not in pyproject:
                    LOG.info(f"{org}/{repo['name']} has no pyproject.toml")
                    continue
                if "build-backend" not in pyproject["build-system"]:
                    LOG.error(
                        f"{org}/{repo['name']} pyproject.toml "
                        "build-backend has no build-system"
                    )
                    continue
                if "cmeel" not in pyproject["build-system"]["build-backend"]:
                    LOG.info(f"{org}/{repo['name']} pyproject is not cmeel based")
                else:
                    repos.append(Pkg.from_pyproject(repo["html_url"], pyproject))
            page += 1
    pprint(repos)
    dot = graphviz.Digraph(format="svg")
    for repo in repos:
        dot.node(repo.name, label=str(repo), URL=repo.source)
        for dep in repo.build_deps:
            dot.edge(dep, repo.name)
    dot.render("distribution.gv")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-t", "--token")
    parser.add_argument("orgs", nargs="*", default=ORGS)
    args = parser.parse_args()
    if args.verbose == 0:
        level = os.environ.get("CMEEL_LOG_LEVEL", "WARNING")
    else:
        level = 30 - 10 * args.verbose
    logging.basicConfig(level=level)
    main(args.token or os.environ["GITHUB_TOKEN"], args.orgs)
