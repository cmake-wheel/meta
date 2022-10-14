#!/usr/bin/env python

import unittest


class TestEigenpy(unittest.TestCase):
    def test_trivial(self):
        import eigenpy
        self.assertLess(abs(eigenpy.Quaternion(1, 2, 3, 4).norm() - 5.47722557505), 1e-7)


class TestHPPFCL(unittest.TestCase):
    def test_trivial(self):
        import hppfcl
        self.assertLess(abs(hppfcl.Capsule(2, 3).computeVolume() - 71.2094334814), 1e-7)


class TestPinocchio(unittest.TestCase):
    def test_trivial(self):
        import pinocchio
        self.assertEqual(str(pinocchio.SE3.Identity().inverse()), '  R =\n1 0 0\n0 1 0\n0 0 1\n  p = -0 -0 -0\n')


class TestNDCurves(unittest.TestCase):
    def test_trivial(self):
        import numpy as np
        import ndcurves
        self.assertTrue(ndcurves.CURVES_WITH_PINOCCHIO_SUPPORT)
        rot_init = ndcurves.Quaternion.Identity().matrix()
        rot_end = ndcurves.Quaternion(2 ** 0.5 / 2, 2 ** 0.5 / 2, 0, 0).matrix()
        waypoints = np.array([[1, 2, 3], [4, 5, 6], [4, 5, 6], [4, 5, 6], [4, 5, 6]]).transpose()
        translation = ndcurves.bezier(waypoints, 0.2, 1.5)
        se3 = ndcurves.SE3Curve(translation, rot_init, rot_end)
        pw = ndcurves.piecewise_SE3(se3)
        self.assertEqual(pw.min(), 0.2)
        self.assertEqual(pw.max(), 1.5)
        self.assertEqual(pw.dim(), 6)

class TestExampleRobotData(unittest.TestCase):
    def test_trivial(self):
        import example_robot_data
        self.assertEqual(example_robot_data.load('talos').model.nq, 39)


class TestTsid(unittest.TestCase):
    def test_import(self):
        import tsid


class TestCrocoddyl(unittest.TestCase):
    def test_import(self):
        import crocoddyl



if __name__ == '__main__':
    unittest.main()
