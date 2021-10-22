import { Dependencies } from "@deliverybot/core";
import { Request, Response } from "express";

export function health({ app }: Dependencies) {
  app.get("/health", (req: Request, res: Response) => res.send("OK"));
}
