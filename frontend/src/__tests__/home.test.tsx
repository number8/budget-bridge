import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

describe("HomePage", () => {
	it("renders the heading", () => {
		render(
			<main>
				<h1>BudgetBridge</h1>
			</main>,
		);
		expect(screen.getByText("BudgetBridge")).toBeInTheDocument();
	});
});
