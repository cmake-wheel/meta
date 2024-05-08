#!/usr/bin/env python

import unittest


class MetaTest(unittest.TestCase):
    def test_eigenpy(self):
        import eigenpy

        self.assertLess(
            abs(eigenpy.Quaternion(1, 2, 3, 4).norm() - 5.47722557505), 1e-7
        )


if __name__ == "__main__":
    unittest.main()
