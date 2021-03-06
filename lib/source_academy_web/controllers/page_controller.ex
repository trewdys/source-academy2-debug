defmodule SourceAcademyWeb.PageController do
  use SourceAcademyWeb, :controller

  alias SourceAcademy.Accounts
  alias SourceAcademy.Assessments

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    if current_user do
      if Accounts.staff?(current_user) do
        redirect conn, to: admin_page_path(conn, :index)
      else
        redirect conn, to: page_path(conn, :game)
      end
    else
      redirect conn, to: auth_path(conn, :login)
    end
  end

  def game(conn, params) do
    user = conn.assigns.current_user
    student = conn.assigns.current_student
    assessment = Assessments.prepare_game(student)
    story_override =
      if Accounts.staff?(user) do
        Map.get(params, "s") || nil
      else
        nil
      end
    if assessment == nil do
      render conn, "game.html",
        assessment_id: -1,
        story: "spaceship",
        username: student.user.first_name,
        story_override: story_override,
        attempted_all: true
    else
      render conn, "game.html",
        assessment_id: assessment.id,
        story: Assessments.story_name(assessment),
        username: student.user.first_name,
        story_override: story_override,
        attempted_all: false
    end
  end
end
