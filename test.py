#!/usr/bin/env python

import unittest


class MetaTest(unittest.TestCase):
    def test_eigenpy(self):
        import eigenpy

        self.assertLess(
            abs(eigenpy.Quaternion(1, 2, 3, 4).norm() - 5.47722557505), 1e-7
        )

    def test_coal(self):
        import coal

        self.assertLess(abs(coal.Capsule(2, 3).computeVolume() - 71.2094334814), 1e-7)

    # def test_pinocchio(self):
    # import pinocchio

    # self.assertEqual(
    # str(pinocchio.SE3.Identity().inverse()),
    # "  R =\n1 0 0\n0 1 0\n0 0 1\n  p = -0 -0 -0\n",
    # )

    # def test_ndcurves(self):
    # import ndcurves
    # import numpy as np

    # self.assertTrue(ndcurves.CURVES_WITH_PINOCCHIO_SUPPORT)
    # rot_init = ndcurves.Quaternion.Identity().matrix()
    # rot_end = ndcurves.Quaternion(2**0.5 / 2, 2**0.5 / 2, 0, 0).matrix()
    # waypoints = np.array(
    # [[1, 2, 3], [4, 5, 6], [4, 5, 6], [4, 5, 6], [4, 5, 6]]
    # ).transpose()
    # translation = ndcurves.bezier(waypoints, 0.2, 1.5)
    # se3 = ndcurves.SE3Curve(translation, rot_init, rot_end)
    # pw = ndcurves.piecewise_SE3(se3)
    # self.assertEqual(pw.min(), 0.2)
    # self.assertEqual(pw.max(), 1.5)
    # self.assertEqual(pw.dim(), 6)

    # def test_example(self):
    # import example_robot_data

    # self.assertEqual(example_robot_data.load("talos").model.nq, 39)

    # def test_tsid(self):
    # import tsid

    # self.assertTrue(hasattr(tsid, "TaskComEquality"))

    # @unittest.skip("need a new release")
    # def test_crocoddyl(self):
    # import crocoddyl

    # self.assertTrue(hasattr(crocoddyl, "ActionDataAbstract"))


if __name__ == "__main__":
    unittest.main()
