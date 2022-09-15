import dataclasses
from pathlib import Path

import pygame
from pygame.color import Color
from pygame import Surface
from abc import ABC, abstractmethod
import sys

from pygame.rect import Rect

DISPLAY_SIZE = (500, 500)
FPS = 60
ASSETS = Path("assets")


class Point:
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y


@dataclasses.dataclass(init=True)
class GameObject(ABC):
    image: Surface
    pos: Point = Point(0, 0)
    size: Point = Point(0, 0)

    @abstractmethod
    def update(self, delta_time: int):
        pass

    @abstractmethod
    def blit(self):
        pass

    @property
    def rect(self) -> Rect:
        return Rect(self.pos.x, self.pos.y, self.size.x, self.size.y)

    def move(self, move_by: Point):
        self.pos.x += move_by.x
        self.pos.y += move_by.y


class Elis(GameObject):
    def __init__(self, pos: Point):
        if not pos:
            pos = Point(0, 0)

        super(Elis, self).__init__(
            image=pygame.image.load(ASSETS / "elisOnAGoose_spritesheet.png").convert_alpha(),
            pos=pos,
            size=Point(112, 112),
        )

        self._ground_y_pos = pos.y

        self._frames = []
        for y in range(0, self.size.y * 3, self.size.y):
            for x in range(0, self.size.x * 5, self.size.x):
                s = Surface((self.size.x, self.size.y), pygame.SRCALPHA)
                s.blit(source=self.image, dest=(0, 0), area=(x, y, self.size.x, self.size.y))
                self._frames.append(s)

        self._current_frame_index = 0
        self._update_count = 0

        self.jumped = False
        self.velocity = 0
        self.acceleration = 0

    @property
    def frame(self):
        return pygame.transform.scale(self._frames[self._current_frame_index], (60, 60))

    def jump(self):
        self.acceleration = -2.0
        self.jumped = True

    def update(self, delta_time: int):
        self._update_count += 1
        if self._update_count >= 2:
            self._current_frame_index = (self._current_frame_index + 1) % len(self._frames)
            self._update_count = 0

        if self.jumped:
            self.velocity += self.acceleration
            self.pos.y += round(self.velocity)
            self.acceleration += 0.2

            if self.pos.y >= self._ground_y_pos:
                self.jumped = False
                self.velocity = 0
                self.acceleration = 0

    def blit(self):
        screen = pygame.display.get_surface()
        screen.blit(self.frame, self.rect)


def main():
    screen = pygame.display.set_mode(DISPLAY_SIZE)
    clock = pygame.time.Clock()

    pygame.init()
    pygame.display.set_caption("elisOnAGoose")
    elis = Elis(pos=Point(x=screen.get_width() // 2, y=screen.get_height()//2))
    game_objects = [elis]

    while True:
        delta_time = clock.tick(FPS)

        # Clear the screen
        screen.fill(Color("darkgrey"))

        for obj in game_objects:
            obj.update(delta_time)
            obj.blit()

        # Get and handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                print("Quiting...")
                sys.exit()

            elif event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                if not elis.jumped:
                    elis.jump()

        pygame.display.update()


if __name__ == '__main__':
    main()

