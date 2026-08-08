import { FiBookOpen, FiUser, FiUsers } from "react-icons/fi";
import Button from "./Button";

export default function CourseGrid({
  courses,
  enrolledCourseIds,
  role,
  onRegister,
  onDrop,
  actionLoadingId,
}: {
  courses: any[];
  enrolledCourseIds: Set<number>;
  role: "student" | "lecturer";
  onRegister: (courseId: number) => void;
  onDrop: (courseId: number) => void;
  actionLoadingId: number | null;
}) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
      {courses.map((c) => {
        const enrolled = enrolledCourseIds.has(c.course_id);
        return (
          <div key={c.course_id} className="card p-5 flex flex-col justify-between animate-fade-in">
            <div>
              <div className="flex items-start justify-between">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                  <FiBookOpen className="h-5 w-5 text-primary" />
                </div>
                <span className="badge-success">{c.credit_hours} credits</span>
              </div>
              <h3 className="mt-3 font-semibold text-textprimary">{c.course_code}</h3>
              <p className="text-sm text-textsecondary">{c.course_title}</p>

              <div className="mt-4 space-y-1.5 text-xs text-textsecondary">
                <p className="flex items-center gap-1.5">
                  <FiUser className="h-3.5 w-3.5" /> {c.lecturer_name || "TBA"}
                </p>
                <p className="flex items-center gap-1.5">
                  <FiUsers className="h-3.5 w-3.5" /> {c.enrolled_count} students enrolled
                </p>
              </div>
            </div>

            {role === "student" && (
              <div className="mt-5">
                {enrolled ? (
                  <Button
                    variant="danger"
                    className="w-full"
                    loading={actionLoadingId === c.course_id}
                    onClick={() => onDrop(c.course_id)}
                  >
                    Drop Course
                  </Button>
                ) : (
                  <Button
                    variant="primary"
                    className="w-full"
                    loading={actionLoadingId === c.course_id}
                    onClick={() => onRegister(c.course_id)}
                  >
                    Register
                  </Button>
                )}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
