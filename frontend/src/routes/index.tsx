import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({
	component: HomePage,
});

function HomePage() {
	return (
		<main className="flex min-h-screen items-center justify-center">
			<div className="text-center">
				<h1 className="text-4xl font-bold">BudgetBridge</h1>
				<p className="mt-4 text-lg text-muted-foreground">
					Simplify your personal finance management
				</p>
			</div>
		</main>
	);
}
