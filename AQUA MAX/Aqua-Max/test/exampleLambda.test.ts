import { describe, it, expect } from 'vitest';
import { handler } from '../lambdas/exampleLambda';

describe('exampleLambda', () => {
  it('should return hello message', async () => {
    const response = await handler({});
    expect(response.statusCode).toBe(200);
    expect(JSON.parse(response.body).message).toBe('Hello from Lambda!');
  });
});